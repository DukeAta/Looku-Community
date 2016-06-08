class SubscribersController < ApplicationController
  def home
  end

  def register
  end

  def create
    Subscriber.create(email: params[:email]) unless Subscriber.where(email: params[:email]).exists?
    redirect_to subscriber_home_path(register: 'success')
  end
end