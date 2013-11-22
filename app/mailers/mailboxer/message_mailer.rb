class Mailboxer::MessageMailer < Mailboxer::BaseMailer
  #Sends and email for indicating a new message or a reply to a receiver.
  #It calls new_message_email if notifing a new message and reply_message_email
  #when indicating a reply to an already created conversation.
  def send_email(message, receiver)
    if message.conversation.messages.size > 1
      reply_message_email(message,receiver)
    else
      new_message_email(message,receiver)
    end
  end

  #Sends an email for indicating a new message for the receiver
  def new_message_email(message,receiver)
    @message  = message
    @receiver = receiver
    set_subject(message)
    mail :to => receiver.send(Mailboxer.email_method, message),
         :subject => t('mailboxer.message_mailer.subject_new', :subject => @subject),
         :template_name => 'new_message_email'
  end

  #Sends and email for indicating a reply in an already created conversation
  def reply_message_email(message,receiver)
    @message  = message
    @receiver = receiver
    set_subject(message)
    mail :to => receiver.send(Mailboxer.email_method, message),
         :subject => t('mailboxer.message_mailer.subject_reply', :subject => @subject),
         :template_name => 'reply_message_email'
  end
end
