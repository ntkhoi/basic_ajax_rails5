###  Giới thiệu về ajax.
Để hiểu về ajax đầu tiên ta phải tìm hiểu về cơ chế “web browse” hoạt động với một trang web bình thường.
 
Khi ta gõ vào trình duyệt http://localhost:3000 và nhấn "Go". Trình duyệt sẽ send một request đến server sau đó nhận response từ server và phân tích tiếp tục request để lấy về những associated asset như javasctipts , stylesheet và image để render ra một web page lung linh. Sau đó bất kỳ lúc nào bạn nhấn một link thì quá trình tương tự lặp lại . Và gian hồ gọi đó là "request response cycle".

Javascript cũng có thể send request đến server , parse response và kiêm luôn cả việc update thông tin trên một view. Do đó có thể dùng javascript để giúp trang web có thể update một phần của trang mà không cần get full page data từ server . Đó là một công nghệ rất mạnh mẽ mà gian hồ gọi là ajax(Asynchronous JavaScript and XML).

### The Basic Rails Chat app. 
Ta bắt tay vào tạo một chat app demo để hiểu về ajax.  
Ở đây tôi dùng  ruby version 2.4.0 và rails version 5.1.0.
1 . ```rails new chat_app```
2 . ```rails g resource message```
3 .  Tìm và edit migrate file (located in db/migrate):

```ruby
class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.string  :body
      t.timestamps null: false
    end
  end
end
```
4 . Trong file messages_controller.rb

```ruby
class MessagesController < ApplicationController
    
    def index
        @messages = Message.all
    end

    def create
        @message = Message.create message_params
        redirect_to root_path
        
    private
    def message_params
        params.require(:message).permit(:body)
    end
end
```
5 . Trong file config/routes.rb

```ruby
#config.rb
Rails.application.routes.draw do
  root 'messages#index'
  resources :messages
end

```
6. Tạo file views/messages/index.html.erb chứa basic form và show các messages 

```html

<h1>My Messages</h1>

<%= form_for Message.new do |f| %>
  <div class="form-group">
    <%= f.text_field :body, placeholder:
    "what needs talking?" %>
  </div>
  <div class="form-group">
  <%= f.submit %>
  </div>
<% end %>

<ul>
<% @messages.each do |message| %>
  <li>
    <%= message.body %><br>
    <%= link_to "delete", message_path(message), method: 'delete' %>
  </li>
<% end %>
</ul>
```
7. Trước khi start server run

```rails db:setup```
```rails db:migrate```
Giờ ta đã có một app có single page sau đây ta bắt đầu create và destroy message  mà không cần phải reload lại page . 
### Post message với ajax
Mặt định trong rails  khi nhấn “create message” button  sẽ gửi một post request  đến action “create” trong “messages_controller” và yêu cầu response_to  html . 
 Bây giờ ta sẽ stop form submittion trong rails thay vào đó ta sẽ send một ajax request  . Để làm điều đó ta thực hiện theo vài bước sau.
1. Thêm  một “event listener” cho form submit vào page sau khi “documents ready” và top reload page.
2. Lấy data từ form .
3. Tạo ajax request.
4. Handle the response và thêm “message” vừa nhận vào page.
##### Tạo event listener
Thêm file messages.js trong app/assets/javascripts/ và thêm đoạn code sau. 

```javascript
// app/assets/javascripts/messages.js
$(function(){  //This is shorthand for $( document ).ready(function() { }) 
  $("form").submit(function(){ // Event listener for form submit
    event.preventDefault(); // 
  });
});
```
##### Lấy data từ form và send một ajax request. 

```javascript
$(function(){
  $("form").submit(function(){
    event.preventDefault();
    var action = $(this).attr('action');
    var method = $(this).attr('method');
    var body = $(this).find('#message_body').val();
     $.ajax({
      method: method,
      url: action,
      data: { message: {body: body} },
      dataType: 'script' // Make sure response is javascript not html
    });
  });
});
```
Xem log từ server  sau khi click “create message” button

>Started POST "/messages" for 127.0.0.1 at 2017-05-06 17:12:17 +0700
Processing by MessagesController#create as */*
  Parameters: {"message"=>{"body"=>"test ajax"}}

Cool Success! . Vậy là đã gửi post request đến create action  bằng ajax . 
##### Handle the response và thêm “message” vừa nhận vào page.
Và bây giờ modify create action.

```ruby
# messages_controller.rb
def create
    @message = Message.create message_params
    respond_to do |format|
        format.js { }
        format.html { redirect_to root_path }
    end
end
```

Mặt định rails response html string . Nhưng bây giờ ta đã yêu cầu rails sẽ response bằng javascript.
Khi rails nhìn thấy dòng code ``` format.js { }``` Nó sẽ tìm  vào file ```app/views/<controller name>/<action name>.js.erb``` và xử lý code trong file đó ở đây là  ```app/views/messages/create.js.erb```.
Do đó ta tạo file create.js.erb và dùng javascript, jquery để thêm message vừa nhận được về vào thẻo <ul>

```javascript
//create.js.erb
var html = "<li><%= @message.body %><br><%= escape_javascript link_to 'done', message_path(@message), method: 'delete' %></li>";
$('ul').append(html);
```
Bây giờ khi nhấn “create button” message đã được thêm vào mà ko reload trang. Done!
Nhưng ở đây vẫn có vài vấn đề cần refactoring.
- Ta đã copy code từ index.html.erb vào create.js.erb nên mỗi khi sửa code ta phải sửa trong 2 file .
- html string thì quá khó để đọc . 

Solution để giải quyết vấn đề này ta dùng partial . Đặt code ở một file khác và gọi trong index.html.erb

```html
<!-- _message.htnl.erb -->
<li>
    <%= message.body %><br>
    <%= link_to "done", message_path(message) , method: 'delete' %>
</li>
```
render trong index.html.erb

```html
<h1>My Messages</h1>

<%= form_for Message.new  do |f|   %>
  <div class="form-group">
    <%= f.text_field :body, placeholder:
    "what needs to talk?" %>
  </div>

  <div class="form-group">
  <%= f.submit %>
  </div>
<% end %>

<ul>
<% @messages.each do |message| %>
  <%= render @messages %>
<% end %>
</ul>
```
Cuối cùng thay thế html string trong create.js.erb bằng render partial

```javascript
$('ul').append("<%= j render partial: 'message' , locals: { message: @message } %>");
```
Ta đã finish create message với ajax . Cách làm trên giúp ta hiểu về basic ajax với rails nhưng trong thực thế rails cung cấp một cách dễ dàng hơn để làm việc với ajax . Xem tiếp phần tiếp nhá .
### Refactoring with remote: true
Trong rails  form_for và link_to có agument remote: true .
Ví dụ :

```<%= link_to 'Show Something', something_path(@something), remote: true %>```
Trong trường hợp của ta . Ta có thểm thêm “remote : true ” vào form.

```html
<%= form_for Message.new , remote:true do |f|   %>
  <div class="form-group">
    <%= f.text_field :body, placeholder:
    "what needs to talk?" %>
  </div>

  <div class="form-group">
  <%= f.submit %>
  </div>
<% end %>
```

Khi gán remote: true vào form . Khi generate html form sẽ được gắn atribute data-remote="true" và submit form tự động bằng ajax  . Do đó ta không cần dùng code trong messages.js nữa

```// app/assets/javascripts/messages.js```

Nếu bạn thực sự muốn biết chi tiết rails làm gì khi gắn remote: true vào form có thể xem qua source của  [rails.js](https://github.com/rails/jquery-ujs/blob/148571ded762f22ccca84db38d4b4d56853ab395/src/rails.js)

### Delete message với remote: true
Tương tự add remote: true to link_to and handle response như trên . 


##### Source code available in [Basic ajax rails5](https://github.com/ntkhoi/basic_ajax_rails5)
 
 



