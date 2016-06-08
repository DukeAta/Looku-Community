class StaticController < ApplicationController

  def contact_us

    if request.post?
      @message = ContactMessage.new(contact_message_params)
      if @message.valid?
        UserMailer.new_message(@message).deliver_now
        redirect_to root_path, :alert => "Your messages has been sent." and return
      else
        flash[:alert] = "All fields are required."
      end
    else
      @message = ContactMessage.new
    end

  end

  def privacy
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :content)
  end

end