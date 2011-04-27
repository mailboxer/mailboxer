class MessageMailer < ActionMailer::Base
  #Sends and email for indicating a new message or a reply to a receiver. 
  #It calls new_message_email if notifing a new message and reply_message_email
  #when indicating a reply to an already created conversation.
  def send_email(message,receiver)    
    if message.conversation.messages.size > 0
      reply_message_email(message,receiver)
    else
      new_message_email(message,receiver)
    end
  end
  
  include ActionView::Helpers::SanitizeHelper

  #Sends an email for indicating a new message for the receiver
  def new_message_email(message,receiver)
    @message = message
    @receiver = receiver
    mail(:to => receiver.email, :subject => "You have a new message: " + strip_tags(message.subject)) do |format|
      format.html {render __method__}
      format.text {render __method__}
    end
  end

  #Sends and email for indicating a reply in an already created conversation
  def reply_message_email(message,receiver)
    @message = message
    @receiver = receiver
    mail(:to => receiver.email, :subject => "You have a new reply: " + strip_tags(message.subject)) do |format|
      format.html {render __method__}
      format.text {render __method__}
    end
  end
end
