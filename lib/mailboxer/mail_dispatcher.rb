module Mailboxer
  class MailDispatcher

    attr_reader :mailable, :recipients

    def initialize(mailable, recipients)
      @mailable, @recipients = mailable, recipients
    end

    def call
      return false unless Mailboxer.uses_emails
      if Mailboxer.mailer_wants_array
        send_email(filtered_recipients)
      else
        filtered_recipients.each do |recipient|
          email_to = recipient.send(Mailboxer.email_method, mailable)
          send_email(recipient) if email_to.present?
        end
      end
    end

    private

    def mailer
      klass = mailable.class.name.demodulize
      method = "#{klass.downcase}_mailer".to_sym
      Mailboxer.send(method) || "#{mailable.class}Mailer".constantize
    end

    # recipients can be filtered on a conversation basis
    def filtered_recipients
      return recipients unless mailable.respond_to?(:conversation)

      recipients.each_with_object([]) do |recipient, array|
        array << recipient if mailable.conversation.has_subscriber?(recipient)
      end
    end

    def send_email(recipient)
      if Mailboxer.custom_deliver_proc
        Mailboxer.custom_deliver_proc.call(mailer, mailable, recipient)
      else
        email = mailer.send_email(mailable, recipient)
        email.respond_to?(:deliver_now) ? email.deliver_now : email.deliver
      end
    end
  end
end
