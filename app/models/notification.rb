class Notification < ActiveRecord::Base

  attr_accessor :recipients
  belongs_to :sender, :polymorphic => :true
  validates_presence_of :subject, :body, :sender
  has_many :receipts
  
  class << self
    def notify_all(recipients,subject,body)
      notification = Notification.new({:body => body, :subject => subject})
      notification.recipients = recipients.is_a?(Array) ? recipients : [recipients]
      notification.recipients = notification.recipients.uniq
      return notification.deliver
    end
  end

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
    end
    temp_receipts.each(&:valid?)
    if temp_receipts.all? { |t| t.errors.empty? }
      temp_receipts.each(&:save!)   #Save receipts
      self.recipients=nil
    end
    return sender_receipt
  end

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

  def receipt_for(participant)
    return Receipt.notification(self).receiver(participant)
  end

  def is_unread?(participant)
    return false if participant.nil?
    return self.receipt_for(participant).unread.count!=0
  end

  include ActionView::Helpers::SanitizeHelper

  def clean
    unless self.subject.nil?
      self.subject = sanitize self.subject
    end
    self.body = sanitize self.body
  end

end
