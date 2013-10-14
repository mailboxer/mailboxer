class Message < Notification
  attr_accessible :attachment if Mailboxer.protected_attributes?

  belongs_to :conversation, :validate => true, :autosave => true
  validates_presence_of :sender

  class_attribute :on_deliver_callback
  protected :on_deliver_callback
  scope :conversation, lambda { |conversation|
    where(:conversation_id => conversation.id)
  }

  mount_uploader :attachment, AttachmentUploader

  include Concerns::ConfigurableMailer

  class << self
    #Sets the on deliver callback method.
    def on_deliver(callback_method)
      self.on_deliver_callback = callback_method
    end
  end

  #Delivers a Message. USE NOT RECOMENDED.
  #Use Mailboxer::Models::Message.send_message instead.
  def deliver(reply = false, should_clean = true)
    self.clean if should_clean

    #Receiver receipts
    temp_receipts = recipients.map { |r| build_receipt(r, 'inbox') }

    #Sender receipt
    sender_receipt = build_receipt(sender, 'sentbox', true)
    temp_receipts << sender_receipt

    temp_receipts.each(&:valid?)
    if temp_receipts.all? { |t| t.errors.empty? }
      temp_receipts.each(&:save!) 	#Save receipts
      #Should send an email?
      if Mailboxer.uses_emails
        if Mailboxer.mailer_wants_array
          send_email(get_mailer,self, recipients)
        else
          recipients.each do |recipient|
            email_to = recipient.send(Mailboxer.email_method, self)
            send_email(get_mailer,self, recipient) if email_to.present?
          end
        end
      end
      if reply
        self.conversation.touch
      end
      self.recipients=nil
      self.on_deliver_callback.call(self) unless self.on_deliver_callback.nil?
    end
    sender_receipt
  end

  private
  def build_receipt(receiver, mailbox_type, is_read = false)
    Receipt.new.tap do |receipt|
      receipt.notification = self
      receipt.is_read = is_read
      receipt.receiver = receiver
      receipt.mailbox_type = mailbox_type
    end
  end
end
