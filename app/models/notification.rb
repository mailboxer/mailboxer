class Notification < ActiveRecord::Base

  attr_accessor :recipients
  belongs_to :sender, :polymorphic => :true
  validates_presence_of :subject, :body, :sender
  
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

  def receipts(participant=nil)
    return Receipt.notification(self).receiver(participant) if participant
    return Receipt.notification(self)
  end

  def is_unread?(participant)
    return false if participant.nil?
    return self.receipts(participant).unread.count!=0
  end

  include ActionView::Helpers::SanitizeHelper

  def clean
    unless self.subject.nil?
      self.subject = sanitize self.subject
    end
    self.body = sanitize self.body
  end

end
