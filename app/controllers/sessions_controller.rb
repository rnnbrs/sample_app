class SessionsController < ApplicationController
  def new
    
  end
  
  def create
    signin_email =    params[:email].downcase
    signin_password = params[:password]
    
    user = User.find_by_email(signin_email)
    
    if user && user.authenticate(signin_password)
      sign_in user
      redirect_to user
    else
      flash.now[:error] = "Invalid combination of email and password"
      render 'new'      
    end
  end
  
  def destroy
    sign_out
    redirect_to root_url
  end
end
