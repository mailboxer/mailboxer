class MailboxerMessage < ActiveRecord::Base
  #any additional info that needs to be sent in a message (ex. I use these to determine request types)
  serialize :headers
  
  attr_accessor :recipients
  
  class_inheritable_accessor :on_deliver_callback
  protected :on_deliver_callback  
  class_inheritable_accessor :on_deliver_clean
  protected :on_deliver_clean
  belongs_to :sender, :polymorphic => :true
  belongs_to :mailboxer_conversation
  has_many :mailboxer_mails
  scope :conversation, lambda { |conversation|    
    where(:mailboxer_conversation_id => conversation.id)
  }
    
  class << self
    def on_deliver(clean_method, callback_method)
      self.on_deliver_clean = clean_method
      self.on_deliver_callback = callback_method
    end
  end  
  
  def deliver(mailbox_type, should_clean = true)
    self.on_deliver_clean.call(self) unless self.on_deliver_clean.nil? or !should_clean
    self.save
    self.recipients.each do |r|
      r.mailbox[mailbox_type] << self
    end
    self.on_deliver_callback.call(self, mailbox_type) unless self.on_deliver_callback.nil?
  end
  
  def get_recipients
    recipients_array = Array.new 
    self.mailboxer_mails.each do |mail|      
      recipients_array << mail.receiver
    end
    return recipients_array
  end
  
end
