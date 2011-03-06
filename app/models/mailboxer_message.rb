class MailboxerMessage < ActiveRecord::Base
  #any additional info that needs to be sent in a message (ex. I use these to determine request types)
  serialize :headers
  
  attr_accessor :recipients
  
  class_inheritable_accessor :on_deliver_callback
  protected :on_deliver_callback  
  belongs_to :sender, :polymorphic => :true
  belongs_to :mailboxer_conversation
  has_many :mailboxer_mails
  
  #delivers a message to the the given mailbox of all recipients, calls the on_deliver_callback if initialized.
  #
  #====params:
  #mailbox_type:: the mailbox to send the message to
  #clean:: calls the clean method if this is set (must be implemented)
  #
  def deliver(mailbox_type, should_clean = true)
    clean if should_clean
    self.save
    self.recipients.each do |r|
      r.mailbox[mailbox_type] << self
    end
    self.on_deliver_callback.call(self, mailbox_type) unless self.on_deliver_callback.nil?
  end
  
  #sets the on_deliver_callback to the passed method. The method call should expect 2 params (message, mailbox_type).
  def MailboxerMessage.on_deliver(method)
    self.on_deliver_callback = method
  end
  
  def get_recipients
    recipients_array = Array.new 
    self.mailboxer_mails.each do |mail|      
      recipients_array << mail.receiver
    end
    return recipients_array
  end
  
  protected
  #[empty method]
  #
  #this gets called when a message is delivered and the clean param is set (default). Implement this if you wish to clean out illegal content such as scripts or anything that will break layout. This is left empty because what is considered illegal content varies.
  def clean
    #strip all illegal content here. (scripts, shit that will break layout, etc.)
  end
end
