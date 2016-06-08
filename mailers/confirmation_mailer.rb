class ConfirmationMailer < Devise::Mailer

   def confirmation_instructions(record, token, opts={})
        # { :subject => "Hi  #{resource.name}, Welcome to Looku.co" }
    
        super
   end

  def reset_password_instructions(record, opts={})
    headers = {
        :subject => "Welcome  #{resource.name}, reset your Looku.co password"
    }
    super
  end

  def unlock_instructions(record, opts={})
    headers = {
        :subject => "Hi  #{resource.name}, unlock your Looku.co account"
    }
    super
  end

end