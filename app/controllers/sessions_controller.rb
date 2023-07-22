class SessionsController < ApplicationController
  before_action :redirect_if_authenticated, only: %i[create new]
  before_action :authenticate_user!, only: [:destroy]

  def create
    @user = params[:user][:identity].match?('@') ? User.find_by(email: params[:user][:identity].downcase) : User.find_by(username: params[:user][:identity])
    if @user
      if @user.unconfirmed?
        redirect_to new_confirmation_path, alert: 'Incorrect Credentials.'
      elsif @user.authenticate(params[:user][:password])
        after_login_path = session[:user_return_to] || root_path
        login @user
        remember(@user) if params[:user][:remember_me] == '1'
        redirect_to after_login_path, notice: 'Signed in.'
      else
        flash.now[:alert] = 'Incorrect Credentials.'
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = 'Incorrect Credentials.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    forget(current_user)
    logout
    redirect_to to_root_path, notice: 'Signed out.'
  end

  def new; end
end
