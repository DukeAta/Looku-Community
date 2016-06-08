class InvitationMailer < ApplicationMailer

  default from: 'notifications@looku.co'

  def invite_email(email, friends_college, name, college)
    @email = email
    @friends_college = friends_college
    @name = name
    @college = college
    subject = if @name.present?
      "#{@name} has invited you on Looku.co"
    else
      "Your friend has invited you on Looku.co"
    end
    mail(to: email, subject: subject)

  end

end
