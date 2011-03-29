class Message < ActiveRecord::Base
  #any additional info that needs to be sent in a message (ex. I use these to determine request types)
  serialize :headers
  
  attr_accessor :recipients
  
  class_inheritable_accessor :on_deliver_callback
  protected :on_deliver_callback  
  belongs_to :sender, :polymorphic => :true
  belongs_to :conversation
  has_many :receipts
  scope :conversation, lambda { |conversation|    
    where(:conversation_id => conversation.id)
  }
    
  class << self
    def on_deliver(callback_method)
      self.on_deliver_callback = callback_method
    end
  end  
  
  def deliver(mailbox_type, should_clean = true)
    self.clean if should_clean
    self.save
    self.recipients.each do |r|
      r.mailbox[mailbox_type] << self
    end
    self.recipients=nil
    self.on_deliver_callback.call(self, mailbox_type) unless self.on_deliver_callback.nil?
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

	def receipts(participant=nil)
		return Receipt.message(self).receiver(participant) if participant
		return Receipt.message(self)
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
