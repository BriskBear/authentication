class SessionsController < ApplicationController
  before_action :redirect_if_authenticated, only: %i[create new]
  before_action :authenticate_user!, only: [:destroy]

  def authenticate_any(identity, password)
    if identity.match?('@')
      User.authenticate_by(email: identity.downcase, password:)
    else
      User.authenticate_by(username: identity, password:)
    end
  end

  def create
    @user = authenticate_any(param[:user][:identity], param[:user][:password])
    if @user
      if @user.unconfirmed?
        redirect_to new_confirmation_path, alert: 'Incorrect Credentials.'
      else
        after_login_path = session[:user_return_to] || root_path
        redirect_to after_login_path, notice: 'Signed in.'
        active_session = login @user
        remember(active_session) if params[:user][:remember_me] == '1'
      end
    else
      flash.now[:alert] = 'Incorrect Credentials.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    forget_active_session
    logout
    redirect_to to_root_path, notice: 'Signed out.'
  end

  def new; end
end
