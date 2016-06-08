class DocumentMailer < ApplicationMailer

  default :from => 'notifications@looku.co'
  default :to => "Umer Bilal <omerpucit@gmail.com>"

  def upload_success(user, document)
    @user = user
    @document = document
    mail(:to => @user.email, :subject => "Hi #{@user.defaul_first_name}, Upload document success!")
  end


end