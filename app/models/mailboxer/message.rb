class Mailboxer::Message < Mailboxer::Notification
  attr_accessible :attachment if Mailboxer.protected_attributes? and !Mailboxer.uses_multiple_attachments
  self.table_name = :mailboxer_notifications

  belongs_to :conversation, :validate => true, :autosave => true
  validates_presence_of :sender

  class_attribute :on_deliver_callback
  protected :on_deliver_callback
  scope :conversation, lambda { |conversation|
    where(:conversation_id => conversation.id)
  }

  has_many :attachments, class_name: 'Mailboxer::Attachment', foreign_key: :notification_id,
           dependent: :destroy if Mailboxer.uses_multiple_attachments
  mount_uploader :attachment, Mailboxer::AttachmentUploader unless Mailboxer.uses_multiple_attachments

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
    receiver_receipts = recipients.map do |r|
      receipts.build(receiver: r, mailbox_type: 'inbox', is_read: false)
    end

    #Sender receipt
    sender_receipt =
      receipts.build(receiver: sender, mailbox_type: 'sentbox', is_read: true)

    if valid?
      save!
      Mailboxer::MailDispatcher.new(self, receiver_receipts).call

      conversation.touch if reply

      self.recipients = nil

      on_deliver_callback.call(self) if on_deliver_callback
    end
    sender_receipt
  end

  if Mailboxer.uses_multiple_attachments
    #This method is defined so that Message builder works with
    #multiple attachments. It uses attachment= method.
    def attachment=(attached_files)
      attached_files = [*attached_files]
      self.attachments.destroy # Replacing old attachments with new ones
      attached_files.each do |file|
        self.attachments << Mailboxer::Attachment.new(file: file)
      end
    end
  end
end
