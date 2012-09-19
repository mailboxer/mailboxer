class Message < Notification
  attr_accessible :attachment

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
    temp_receipts = Array.new
    #Receiver receipts
    self.recipients.each do |r|
      msg_receipt = Receipt.new
      msg_receipt.notification = self
      msg_receipt.is_read = false
      msg_receipt.receiver = r
      msg_receipt.mailbox_type = "inbox"
      temp_receipts << msg_receipt
    end
    #Sender receipt
    sender_receipt = Receipt.new
    sender_receipt.notification = self
    sender_receipt.is_read = true
    sender_receipt.receiver = self.sender
    sender_receipt.mailbox_type = "sentbox"
    temp_receipts << sender_receipt

    temp_receipts.each(&:valid?)
    if temp_receipts.all? { |t| t.errors.empty? }
      temp_receipts.each(&:save!) 	#Save receipts
      self.recipients.each do |r|
      #Should send an email?
        if Mailboxer.uses_emails
          email_to = r.send(Mailboxer.email_method,self)
          unless email_to.blank?
            get_mailer.send_email(self,r).deliver
          end
        end
      end
      if reply
        self.conversation.touch
      end
      self.recipients=nil
    self.on_deliver_callback.call(self) unless self.on_deliver_callback.nil?
    end
    return sender_receipt
  end
end
