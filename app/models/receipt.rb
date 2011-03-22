class Receipt < ActiveRecord::Base
  belongs_to :message
  has_one :conversation, :through => :message
  belongs_to :receiver, :polymorphic => :true
  scope :receiver, lambda { |receiver|
    where(:receiver_id => receiver.id,:receiver_type => receiver.class.to_s)
  }
  scope :message, lambda { |message|
    where(:message_id => message.id)
  }
  scope :conversation, lambda { |conversation|    
    joins(:message).where('messages.conversation_id' => conversation.id)
  }
  scope :sentbox, where(:mailbox_type => "sentbox")
  scope :inbox, where(:mailbox_type => "inbox")
  scope :trash, where(:trashed => true)
  scope :not_trash, where(:trashed => false)
  scope :read, where(:read => true)
  scope :unread, where(:read => false)
  
  class << self 
    def mark_as_read(options={})    
      where(options).update_all(:read => true)
    end
    
    def mark_as_unread(options={}) 
      where(options).update_all(:read => false)
    end
    
    def move_to_trash(options={})     
      where(options).update_all(:trashed => true)
    end
    
    def untrash(options={})     
      where(options).update_all(:trashed => false)
    end
    
    def move_to_inbox(options={})     
      where(options).update_all(:mailbox_type => :inbox, :trashed => false)
    end
    
    def move_to_sentbox(options={})     
      where(options).update_all(:mailbox_type => :sentbox, :trashed => false)
    end
  end 
  
  def mark_as_read 
    update_attributes(:read => true)
  end

  def mark_as_unread
    update_attributes(:read => false)
  end
  
  def move_to_trash
    update_attributes(:trashed => true)
  end
  
  def untrash
    update_attributes(:trashed => false)
  end
  
  def move_to_inbox
    update_attributes(:mailbox_type => :inbox, :trashed => false)
  end
  
  def move_to_sentbox
    update_attributes(:mailbox_type => :sentbox, :trashed => false)
  end

end
