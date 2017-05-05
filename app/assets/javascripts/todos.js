$(function(){
  $("form").submit(function(){
    // this debugger should be hit when you click the submit button!
    // debugger;


    event.preventDefault();

    var action = $(this).attr('action');
    var method = $(this).attr('method');

    var description = $(this).find('#todo_description').val();
    var priority = $(this).find('#todo_priority').val();

     $.ajax({
        
      method: method,
      url: action,
      data: { todo: {description: description, priority: priority} },
       // this line makes the response format JavaScript and not html.
      dataType: 'script'
    });
    

  });
});
