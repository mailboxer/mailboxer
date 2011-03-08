class MailboxerMail < ActiveRecord::Base
  belongs_to :mailboxer_message
  has_one :mailboxer_conversation, :through => :mailboxer_message
  belongs_to :receiver, :polymorphic => :true
  scope :receiver, lambda { |receiver|
    where(:receiver_id => receiver.id,:receiver_type => receiver.class.to_s)
  }
  scope :message, lambda { |message|
    where(:mailboxer_message_id => message.id)
  }
  scope :conversation, lambda { |conversation|    
    joins(:mailboxer_message).where('mailboxer_messages.mailboxer_conversation_id' => conversation.id)
  }
  scope :sentbox, where(:mailbox_type => "sentbox")
  scope :inbox, where(:mailbox_type => "inbox")
  scope :trash, where(:trashed => true)
  scope :read, where(:read => true)
  scope :unread, where(:read => false)
  
  #sets the read attribute of the mail message to true.
  def mark_as_read 
    update_attribute('read', true)
  end
  
  class << self 
    def mark_all_as_read    
      update_all(:read => true)
    end
    def mark_all_as_unread    
      update_all(:read => false)
    end
  end 
  #sets the read attribute of the mail message to false.
  def mark_as_unread
    update_attribute('read', false)
  end
  
  #  def mailboxer_conversation
  #    return self.mailboxer_message.mailboxer_conversation
  #  end
  
end
