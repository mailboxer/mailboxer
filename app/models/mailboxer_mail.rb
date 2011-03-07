class MailboxerMail < ActiveRecord::Base
  belongs_to :mailboxer_message
  has_one :mailboxer_conversation, :through => :mailboxer_message
  belongs_to :receiver, :polymorphic => :true
  scope :receiver, lambda { |receiver|
    where(:receiver_id => receiver.id,:receiver_type => receiver.class.to_s)
  }
  #sets the read attribute of the mail message to true.
  def mark_as_read 
    update_attribute('read', true)
  end
  
  #sets the read attribute of the mail message to false.
  def mark_as_unread
    update_attribute('read', false)
  end
  
  #  def mailboxer_conversation
  #    return self.mailboxer_message.mailboxer_conversation
  #  end
  
end
