class Message < ActiveRecord::Base
  #any additional info that needs to be sent in a message (ex. I use these to determine request types)
  serialize :headers
  
  attr_accessor :recipients
  validates_presence_of :subject, :body, :sender  
  validates_associated :conversation
  
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
  
  def deliver(reply = false, should_clean = true)
    self.clean if should_clean
    temp_receipts = Array.new
    #Receiver receipts
    self.recipients.each do |r|
      msg_receipt = Receipt.new
	  msg_receipt.message = self
	  msg_receipt.read = false
	  msg_receipt.receiver = r
	  msg_receipt.mailbox_type = "inbox"
   	  temp_receipts << msg_receipt
    end
    #Sender receipt
    sender_receipt = Receipt.new
	sender_receipt.message = self
	sender_receipt.read = true
	sender_receipt.receiver = self.sender
	sender_receipt.mailbox_type = "sentbox"
   	temp_receipts << sender_receipt
    
 	if temp_receipts.each(&:valid?)
		temp_receipts.each(&:save) 	#Save receipts
		self.save					#Save message
		if reply
			self.conversation.update_attribute(:updated_at, Time.now)
		else
			self.conversation.save  	#Save conversation*
		end
		self.recipients=nil
		self.on_deliver_callback.call(self) unless self.on_deliver_callback.nil?
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
