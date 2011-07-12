class Notification < ActiveRecord::Base

  attr_accessor :recipients
  belongs_to :sender, :polymorphic => :true
  belongs_to :object, :polymorphic => :true
  validates_presence_of :subject, :body
  has_many :receipts, :dependent => :destroy
  
  scope :recipient, lambda { |recipient|
    joins(:receipts).where('receipts.receiver_id' => recipient.id,'receipts.receiver_type' => recipient.class.to_s)
  }
  scope :with_object, lambda { |obj|
    where('object_id' => obj.id,'object_type' => obj.class.to_s)
  }    
  scope :not_trashed, lambda {
    joins(:receipts).where('receipts.trashed' => false)
  }
  scope :unread,  lambda {
    joins(:receipts).where('receipts.read' => false)
  }
  
  class << self
    #Sends a Notification to all the recipients
    def notify_all(recipients,subject,body,object = nil)
      notification = Notification.new({:body => body, :subject => subject})
      notification.recipients = recipients.is_a?(Array) ? recipients : [recipients]
      notification.recipients = notification.recipients.uniq
      notification.object = object if object.present?
      return notification.deliver
    end
  end

  #Delivers a Notification. USE NOT RECOMENDED.
  #Use Mailboxer::Models::Message.notify and Notification.notify_all instead.
  def deliver(should_clean = true)
    self.clean if should_clean
    temp_receipts = Array.new
    #Receiver receipts
    self.recipients.each do |r|
      msg_receipt = Receipt.new
      msg_receipt.notification = self
      msg_receipt.read = false
      msg_receipt.receiver = r
      temp_receipts << msg_receipt      
      #Should send an email?
      if Mailboxer.uses_emails and r.send(Mailboxer.should_email_method,self)
        NotificationMailer.send_email(self,r).deliver
      end
    end
    temp_receipts.each(&:valid?)
    if temp_receipts.all? { |t| t.errors.empty? }
      temp_receipts.each(&:save!)   #Save receipts
      self.recipients=nil
    end
    return temp_receipts if temp_receipts.size > 1
    return temp_receipts.first
  end
  
  #Returns the recipients of the Notification
  def recipients
    if @recipients.blank?
      recipients_array = Array.new
      self.receipts.each do |receipt|
        recipients_array << receipt.receiver
      end
    return recipients_array
    end
    return @recipients
  end

  #Returns the receipt for the participant
  def receipt_for(participant)
    return Receipt.notification(self).recipient(participant)
  end
  
  #Returns the receipt for the participant. Alias for receipt_for(participant)
  def receipts_for(participant)
    return receipt_for(participant)
  end

  #Returns if the participant have read the Notification
  def is_unread?(participant)
    return false if participant.nil?
    return !self.receipt_for(participant).first.read
  end

  #Returns if the participant have trashed the Notification
  def is_trashed?(participant)
    return false if participant.nil?
    return self.receipt_for(participant).first.trashed
  end  

  #Mark the notification as read
  def mark_as_read(participant)
    return if participant.nil?
    return self.receipt_for(participant).mark_as_read
  end

  #Mark the notification as unread
  def mark_as_unread(participant)
    return if participant.nil?
    return self.receipt_for(participant).mark_as_unread
  end

  #Move the notification to the trash
  def move_to_trash(participant)
    return if participant.nil?
    return self.receipt_for(participant).move_to_trash
  end

  #Takes the notification out of the trash 
  def untrash(participant)
    return if participant.nil?
    return self.receipt_for(participant).untrash
  end


  include ActionView::Helpers::SanitizeHelper

  #Sanitizes the body and subject
  def clean
    unless self.subject.nil?
      self.subject = sanitize self.subject
    end
    self.body = sanitize self.body
  end

end
