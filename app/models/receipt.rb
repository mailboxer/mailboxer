class Receipt < ActiveRecord::Base
	belongs_to :notification, :validate => true, :autosave => true
	belongs_to :receiver, :polymorphic => :true
	belongs_to :message, :foreign_key => "notification_id" 
	
	validates_presence_of :receiver

	scope :receiver, lambda { |receiver|
    where(:receiver_id => receiver.id,:receiver_type => receiver.class.to_s)
  }
	scope :notification, lambda { |notification|
    where(:notification_id => notification.id)
  }
	scope :conversation, lambda { |conversation|
    joins(:notification).where('notifications.conversation_id' => conversation.id)
  }
	scope :sentbox, where(:mailbox_type => "sentbox")
	scope :inbox, where(:mailbox_type => "inbox")
	scope :trash, where(:trashed => true)
	scope :not_trash, where(:trashed => false)
	scope :read, where(:read => true)
	scope :unread, where(:read => false)

	after_validation :remove_duplicate_errors
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

  def conversation
    return nil if notification.class == Notification
    return notification.conversation if notification.class == Message
  end

	protected

	def remove_duplicate_errors
		if self.errors["message.conversation.subject"].present? and self.errors["message.subject"].present?
			self.errors["message.conversation.subject"].each do |msg|
				self.errors["message.conversation.subject"].delete(msg)
			end
		end
	end

end
