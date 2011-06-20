class Receipt < ActiveRecord::Base
	belongs_to :notification, :validate => true, :autosave => true
	belongs_to :receiver, :polymorphic => :true
	belongs_to :message, :foreign_key => "notification_id" 
	
	validates_presence_of :receiver

	scope :receiver, lambda { |receiver|
    where(:receiver_id => receiver.id,:receiver_type => receiver.class.to_s)
  }
  #Notifications Scope checks type to be nil, not Notification because of STI behaviour
  #with the primary class (no type is saved)
  scope :notifications_receipts, joins(:notification).where('notifications.type' => nil)
  scope :messages_receipts, joins(:notification).where('notifications.type' => Message.to_s)
	scope :notification, lambda { |notification|
    where(:notification_id => notification.id)
  }
	scope :conversation, lambda { |conversation|
    joins(:message).where('notifications.conversation_id' => conversation.id)
  }
	scope :sentbox, where(:mailbox_type => "sentbox")
	scope :inbox, where(:mailbox_type => "inbox")
	scope :trash, where(:trashed => true)
	scope :not_trash, where(:trashed => false)
	scope :read, where(:read => true)
	scope :unread, where(:read => false)

	after_validation :remove_duplicate_errors
	class << self
	  
    #Marks all the receipts from the relation as read
		def mark_as_read(options={})
			where(options).update_all(:read => true)
		end

    #Marks all the receipts from the relation as unread
		def mark_as_unread(options={})
			where(options).update_all(:read => false)
		end

    #Marks all the receipts from the relation as trashed
		def move_to_trash(options={})
			where(options).update_all(:trashed => true)
		end

    #Marks all the receipts from the relation as not trashed
		def untrash(options={})
			where(options).update_all(:trashed => false)
		end

    #Moves all the receipts from the relation to inbox
		def move_to_inbox(options={})
			where(options).update_all(:mailbox_type => :inbox, :trashed => false)
		end

    #Moves all the receipts from the relation to sentbox
		def move_to_sentbox(options={})
			where(options).update_all(:mailbox_type => :sentbox, :trashed => false)
		end
	end

  #Marks the receipt as read
	def mark_as_read
		update_attributes(:read => true)
	end

  #Marks the receipt as unread
	def mark_as_unread
		update_attributes(:read => false)
	end

  #Marks the receipt as trashed
	def move_to_trash
		update_attributes(:trashed => true)
	end

  #Marks the receipt as not trashed
	def untrash
		update_attributes(:trashed => false)
	end

  #Moves the receipt to inbox
	def move_to_inbox
		update_attributes(:mailbox_type => :inbox, :trashed => false)
	end

  #Moves the receipt to sentbox
	def move_to_sentbox
		update_attributes(:mailbox_type => :sentbox, :trashed => false)
	end

  #Returns the conversation associated to the receipt if the notification is a Message
  def conversation
    return message.conversation if message.is_a? Message
    return nil
  end

	protected

  #Removes the duplicate error about not present subject from Conversation if it has been already
  #raised by Message
	def remove_duplicate_errors
		if self.errors["notification.conversation.subject"].present? and self.errors["notification.subject"].present?
			self.errors["notification.conversation.subject"].each do |msg|
				self.errors["notification.conversation.subject"].delete(msg)
			end
		end
	end

end
