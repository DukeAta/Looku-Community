class UserMailer < ApplicationMailer

  default :from => 'notifications@looku.co'
  default :to => "Umer Bilal <omerpucit@gmail.com>"

  def after_email_confirmation(user)
    @user = user
    mail(:to => @user.email, :subject => "Hi #{@user.defaul_first_name}, Welcome to Looku!")
  end

  def new_message(message)
    @message = message
    mail :subject => "Message from #{message.name}"
  end

end