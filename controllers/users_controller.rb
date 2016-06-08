class UsersController < ApplicationController
  before_action :authenticate_user!, :except => [:invite, :after_sign_up]

  def show
  end
  
  def get_documents
    @documents = current_user.documents
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]
    if @user.update_attributes user_params
      redirect_to root_path, alert: "Your Paypal Account has been updated"
    else
      render "edit"
    end
  end

  def invite
    email_regx = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    friends_college = if params[:friends_college].present?
      params[:friends_college]
    else
      ""
    end

    name = if params[:name].present?
      params[:name]
    else
      ""
    end

    college = if params[:college].present?
      params[:college]
    else
      ""
    end

    if params[:friends_email].present?
      valid_emails = []
      bad_emails = []
      params[:friends_email].split(",").map(&:strip).each do |email|
        if email  =~ email_regx
          if session[:invited_emails].present? and !(session[:invited_emails].include?(email))
              valid_emails << email
              session[:invited_emails] << email
          elsif session[:invited_emails].blank?
            session[:invited_emails] = [email]
            valid_emails << email
          end
        else
          bad_emails << email
        end
      end

      if valid_emails.present?
        valid_emails.each do |friend|
          InvitationMailer.invite_email(friend, friends_college, name, college).deliver_now
        end
        redirect_to root_path, :flash => { :alert => "Invitation has sent to your friends." } and return
      elsif (bad_emails.present? and valid_emails.blank?) or ( bad_emails.blank? and  valid_emails.blank?)
        redirect_to root_path, :flash => { :alert => "You have already invited all of these friends." } and return
      end

    else
      if inviter_params[:friends_email].present?
        error = "Please enter valid email address of your friend."
      else
        error = "Please fill required fields."
      end
      redirect_to root_path, :flash => { :alert => error } and return
    end
  end


  def invite_friends
  end

  def after_sign_up
  end

  private

  def user_params
    params.require(:user).permit :paypal_account
  end
end