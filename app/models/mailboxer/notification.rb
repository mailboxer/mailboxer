class Mailboxer::Notification < ActiveRecord::Base
  self.table_name = :mailboxer_notifications

  attr_accessor :recipients
  attr_accessible :body, :subject, :global, :expires if Mailboxer.protected_attributes?

  belongs_to :sender, :polymorphic => :true, :required => false
  belongs_to :notified_object, :polymorphic => :true, :required => false
  has_many :receipts, :dependent => :destroy, :class_name => "Mailboxer::Receipt"

  validates :subject, :length => { :maximum => Mailboxer.subject_max_length }
  validates :body,    :presence => true,
                      :length => { :maximum => Mailboxer.body_max_length }

  scope :recipient, lambda { |recipient|
    joins(:receipts).where(:mailboxer_receipts => { :receiver_id  => recipient.id, :receiver_type => recipient.class.base_class.to_s })
  }
  scope :with_object, lambda { |obj|
    where(:notified_object_id => obj.id, :notified_object_type => obj.class.to_s)
  }
  scope :not_trashed, lambda {
    joins(:receipts).where(:mailboxer_receipts => { :trashed => false })
  }
  scope :unread,  lambda {
    joins(:receipts).where(:mailboxer_receipts => { :is_read => false })
  }
  scope :global, lambda { where(:global => true) }
  scope :expired, lambda { where("#{Mailboxer::Notification.quoted_table_name}.expires < ?", Time.now) }
  scope :unexpired, lambda {
    where("#{Mailboxer::Notification.quoted_table_name}.expires is NULL OR #{Mailboxer::Notification.quoted_table_name}.expires > ?", Time.now)
  }

  class << self
    #Sends a Notification to all the recipients
    def notify_all(recipients, subject, body, obj = nil, sanitize_text = true, notification_code=nil, send_mail=true, sender=nil)
      notification = Mailboxer::NotificationBuilder.new({
        :recipients        => recipients,
        :subject           => subject,
        :body              => body,
        :notified_object   => obj,
        :notification_code => notification_code,
        :sender            => sender
      }).build

      notification.deliver sanitize_text, send_mail
    end

    #Takes a +Receipt+ or an +Array+ of them and returns +true+ if the delivery was
    #successful or +false+ if some error raised
    def successful_delivery? receipts
      case receipts
      when Mailboxer::Receipt
        receipts.valid?
      when Array
        receipts.all?(&:valid?)
      else
        false
      end
    end
  end

  def expired?
    expires.present? && (expires < Time.now)
  end

  def expire!
    unless expired?
      expire
      save
    end
  end

  def expire
    unless expired?
      self.expires = Time.now - 1.second
    end
  end

  #Delivers a Notification. USE NOT RECOMENDED.
  #Use Mailboxer::Models::Message.notify and Notification.notify_all instead.
  def deliver(should_clean = true, send_mail = true)
    clean if should_clean
    temp_receipts = recipients.map do |r|
      receipts.build(receiver: r, mailbox_type: nil, is_read: false)
    end

    if valid?
      Mailboxer::MailDispatcher.new(self, temp_receipts).call if send_mail
      save!

      self.recipients = nil
    end

    return temp_receipts if temp_receipts.size > 1
    temp_receipts.first
  end

  #Returns the recipients of the Notification
  def recipients
    return Array.wrap(@recipients) unless @recipients.blank?
    recipients  = receipts.includes(:receiver).map(&:receiver)
    @recipients = Mailboxer::RecipientFilter.new(self, recipients).call
  end

  #Returns the receipt for the participant
  def receipt_for(participant)
    Mailboxer::Receipt.notification(self).recipient(participant)
  end

  #Returns the receipt for the participant. Alias for receipt_for(participant)
  def receipts_for(participant)
    receipt_for(participant)
  end

  #Returns if the participant have read the Notification
  def is_unread?(participant)
    return false if participant.nil?
    !receipt_for(participant).first.is_read
  end

  def is_read?(participant)
    !is_unread?(participant)
  end

  #Returns if the participant have trashed the Notification
  def is_trashed?(participant)
    return false if participant.nil?
    receipt_for(participant).first.trashed
  end

  #Returns if the participant have deleted the Notification
  def is_deleted?(participant)
    return false if participant.nil?
    return receipt_for(participant).first.deleted
  end

  #Mark the notification as read
  def mark_as_read(participant)
    return if participant.nil?
    receipt_for(participant).mark_as_read
  end

  #Mark the notification as unread
  def mark_as_unread(participant)
    return if participant.nil?
    receipt_for(participant).mark_as_unread
  end

  #Move the notification to the trash
  def move_to_trash(participant)
    return if participant.nil?
    receipt_for(participant).move_to_trash
  end

  #Takes the notification out of the trash
  def untrash(participant)
    return if participant.nil?
    receipt_for(participant).untrash
  end

  #Mark the notification as deleted for one of the participant
  def mark_as_deleted(participant)
    return if participant.nil?
    return receipt_for(participant).mark_as_deleted
  end

  #Sanitizes the body and subject
  def clean
    self.subject = sanitize(subject) if subject
    self.body    = sanitize(body)
  end

  #Returns notified_object. DEPRECATED
  def object
    warn "DEPRECATION WARNING: use 'notified_object' instead of 'object' to get the object associated with the Notification"
    notified_object
  end

  def sanitize(text)
    ::Mailboxer::Cleaner.instance.sanitize(text)
  end
end
