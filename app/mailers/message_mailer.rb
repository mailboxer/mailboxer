class MessageMailer < ActionMailer::Base
  default :from => Mailboxer.default_from
  #Sends and email for indicating a new message or a reply to a receiver. 
  #It calls new_message_email if notifing a new message and reply_message_email
  #when indicating a reply to an already created conversation.
  def send_email(message,receiver)    
    if message.conversation.messages.size > 1 
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
    subject = message.subject.to_s
    subject = strip_tags(subject) unless subject.html_safe?
    mail(:to => receiver.send(Mailboxer.email_method,message), :subject => t('mailboxer.message_mailer.subject_new', :subject => subject)) do |format|
      format.text {render __method__}
      format.html {render __method__}
    end
  end

  #Sends and email for indicating a reply in an already created conversation
  def reply_message_email(message,receiver)
    @message = message
    @receiver = receiver
    subject = message.subject.to_s
    subject = strip_tags(subject) unless subject.html_safe?
    mail(:to => receiver.send(Mailboxer.email_method,message), :subject => t('mailboxer.message_mailer.subject_reply', :subject => subject)) do |format|
      format.text {render __method__}
      format.html {render __method__}
    end
  end
end
