class NotificationMailer < ActionMailer::Base
  default :from => Mailboxer.default_from
  #Sends and email for indicating a new notification to a receiver.
  #It calls new_notification_email.
  def send_email(notification,receiver)
    new_notification_email(notification,receiver)
  end

  include ActionView::Helpers::SanitizeHelper

  #Sends an email for indicating a new message for the receiver
  def new_notification_email(notification,receiver)
    @notification = notification
    @receiver = receiver
    subject = message.subject.to_s
    subject = strip_tags(subject) unless subject.html_safe?
    mail(:to => receiver.send(Mailboxer.email_method), :subject => "You have a new notification: " + subject) do |format|
      format.html {render __method__}
      format.text {render __method__}
    end
  end
end
