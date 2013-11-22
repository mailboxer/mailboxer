module Mailboxer
  class MailDispatcher

    attr_reader :mailable, :recipients

    def initialize(mailable, recipients)
      @mailable, @recipients = mailable, recipients
    end

    def call
      return false unless Mailboxer.uses_emails
      if Mailboxer.mailer_wants_array
        send_email(recipients)
      else
        recipients.each do |recipient|
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

    def send_email(recipient)
      if Mailboxer.custom_deliver_proc
        Mailboxer.custom_deliver_proc.call(mailer, mailable, recipient)
      else
        mailer.send_email(mailable, recipient).deliver
      end
    end

  end
end
