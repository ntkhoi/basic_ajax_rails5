class TodosController < ApplicationController
    def index
        @todos = Todo.all
    end

    def create
        # if our ajax request works, we'll hit this binding at take a look at params!
        # binding.pry
        @todo = Todo.create todo_params
        # binding.pry
        respond_to do |format|
            format.js { }
            format.html { redirect_to root_path }
            
        end
    end

    def destroy 
        todo = Todo.find(params[:id])
        todo.destroy
        redirect_to root_path
    end

    
    private
    def todo_params
        params.require(:todo).permit(:description , :priority)
    end
    
    
end
