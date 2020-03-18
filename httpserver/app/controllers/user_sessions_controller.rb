class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])

    if @user_session.save then
      redirect_back_or_default :root, :notice => 'ログインしました'
    else
      render :action => 'new', :notice => 'ログインに失敗しました'
    end
  end

  def destroy
    current_user_session.destroy
    redirect_back_or_default :root, :notice => 'ログアウトしました'
  end
end
