class MessagesController < ApplicationController
    
    def index
        @messages = Message.all
    end

    def create
        #  binding.pry
        @message = Message.create message_params
        respond_to do |format|
            format.js { }
            format.html { redirect_to root_path }
            
        end
    end

    def destroy 
        @message = Message.find(params[:id])
        @message.destroy
       respond_to do |format|
          format.html { redirect_to root_path }
          format.js { }
       end
    end

    
    private
    def message_params
        params.require(:message).permit(:body)
    end
     
end
