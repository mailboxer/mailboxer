class Notification < ActiveRecord::Base

  attr_accessor :recipients
  belongs_to :sender, :polymorphic => :true
  validates_presence_of :subject, :body
  has_many :receipts
  
  scope :receiver, lambda { |receiver|
    joins(:receipts).where('receipts.receiver_id' => receiver.id,'receipts.receiver_type' => receiver.class.to_s)
  }
  
  class << self
    #Sends a Notification to all the recipients
    def notify_all(recipients,subject,body)
      notification = Notification.new({:body => body, :subject => subject})
      notification.recipients = recipients.is_a?(Array) ? recipients : [recipients]
      notification.recipients = notification.recipients.uniq
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
      if r.should_email? self
        MessageMailer.send_email(self,r)
      end
    end
    temp_receipts.each(&:valid?)
    if temp_receipts.all? { |t| t.errors.empty? }
      temp_receipts.each(&:save!)   #Save receipts
      self.recipients=nil
    end
    return temp_receipts
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
    return Receipt.notification(self).receiver(participant)
  end

  #Returns if the participant have read the Notification
  def is_unread?(participant)
    return false if participant.nil?
    return self.receipt_for(participant).unread.count!=0
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
