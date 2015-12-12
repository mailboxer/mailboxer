module Mailboxer
  class MailDispatcher
    attr_reader :mailable, :receipts

    def initialize(mailable, receipts)
      @mailable, @receipts = mailable, receipts
    end

    def call
      return false unless Mailboxer.uses_emails

      receipts.map do |receipt|
        email_to = receipt.receiver.send(Mailboxer.email_method, mailable)
        send_email(receipt) if email_to.present?
      end
    end

    private

    def mailer
      klass = mailable.class.name.demodulize
      method = "#{klass.downcase}_mailer".to_sym
      Mailboxer.send(method) || "#{mailable.class}Mailer".constantize
    end

    def send_email(receipt)
      if Mailboxer.custom_deliver_proc
        Mailboxer.custom_deliver_proc.call(mailer, mailable, receipt.receiver)
      else
        default_send_email(receipt)
      end
    end

    def default_send_email(receipt)
      mail = mailer.send_email(mailable, receipt.receiver)
      mail.respond_to?(:deliver_now) ? mail.deliver_now : mail.deliver
      receipt.assign_attributes(
        :delivery_method => :email,
        :message_id => mail.message_id
      )
      mail
    end
  end
end
