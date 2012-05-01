class Conversation < ActiveRecord::Base
	has_many :messages, :dependent => :destroy
	has_many :receipts, :through => :messages

	validates_presence_of :subject

	before_validation :clean

	scope :participant, lambda {|participant|
    joins(:receipts).select('DISTINCT conversations.*').where('notifications.type'=> Message.to_s,'receipts.receiver_id' => participant.id,'receipts.receiver_type' => participant.class.to_s).order("conversations.updated_at DESC")
  }
	scope :inbox, lambda {|participant|
    joins(:receipts).select('DISTINCT conversations.*').where('notifications.type'=> Message.to_s,'receipts.receiver_id' => participant.id,'receipts.receiver_type' => participant.class.to_s, 'receipts.mailbox_type' => 'inbox','receipts.trashed' => false).order("conversations.updated_at DESC")
  }
	scope :sentbox, lambda {|participant|
    joins(:receipts).select('DISTINCT conversations.*').where('notifications.type'=> Message.to_s,'receipts.receiver_id' => participant.id,'receipts.receiver_type' => participant.class.to_s, 'receipts.mailbox_type' => 'sentbox','receipts.trashed' => false).order("conversations.updated_at DESC")
  }
	scope :trash, lambda {|participant|
    joins(:receipts).select('DISTINCT conversations.*').where('notifications.type'=> Message.to_s,'receipts.receiver_id' => participant.id,'receipts.receiver_type' => participant.class.to_s,'receipts.trashed' => true).order("conversations.updated_at DESC")
  }
	scope :unread,  lambda {|participant|
    joins(:receipts).select('DISTINCT conversations.*').where('notifications.type'=> Message.to_s,'receipts.receiver_id' => participant.id,'receipts.receiver_type' => participant.class.to_s,'receipts.read' => false).order("conversations.updated_at DESC")
  }

  #Mark the conversation as read for one of the participants
	def mark_as_read(participant)
		return if participant.nil?
		return self.receipts_for(participant).mark_as_read
	end

  #Mark the conversation as unread for one of the participants
	def mark_as_unread(participant)
		return if participant.nil?
		return self.receipts_for(participant).mark_as_unread
	end

  #Move the conversation to the trash for one of the participants
	def move_to_trash(participant)
		return if participant.nil?
		return self.receipts_for(participant).move_to_trash
	end

  #Takes the conversation out of the trash for one of the participants
	def untrash(participant)
		return if participant.nil?
		return self.receipts_for(participant).untrash
	end

  #Returns an array of participants
	def recipients
		if self.last_message
			recps = self.last_message.recipients
			recps = recps.is_a?(Array) ? recps : [recps]
		return recps
		end
		return []
	end
	
  #Returns an array of participants
	def participants
	  return recipients
	end

	#Originator of the conversation.
	def originator
		@orignator = self.original_message.sender if @originator.nil?
		return @orignator
	end

	#First message of the conversation.
	def original_message
		@original_message = self.messages.find(:first, :order => 'created_at') if @original_message.nil?
		return @original_message
	end

	#Sender of the last message.
	def last_sender
		@last_sender = self.last_message.sender if @last_sender.nil?
		return @last_sender
	end

	#Last message in the conversation.
	def last_message
		@last_message = self.messages.find(:first, :order => 'created_at DESC') if @last_message.nil?
		return @last_message
	end

  #Returns the receipts of the conversation for one participants
	def receipts_for(participant)
	  return Receipt.conversation(self).recipient(participant)
	end

  #Returns the number of messages of the conversation
	def count_messages
		return Message.conversation(self).count
	end

  #Returns true if the messageable is a participant of the conversation
	def is_participant?(participant)
		return false if participant.nil?
		return self.receipts_for(participant).count != 0
	end

  #Returns true if the participant has at least one trashed message of the conversation
	def is_trashed?(participant)
		return false if participant.nil?
		return self.receipts_for(participant).trash.count!=0
	end

  #Returns true if the participant has trashed all the messages of the conversation
	def is_completely_trashed?(participant)
		return false if participant.nil?
		return self.receipts_for(participant).trash.count == self.receipts_for(participant).count
	end

  #Returns true if the participant has at least one unread message of the conversation
	def is_unread?(participant)
		return false if participant.nil?
		return self.receipts_for(participant).not_trash.unread.count!=0
	end

	protected

	include ActionView::Helpers::SanitizeHelper

  #Use the default sanitize to clean the conversation subject
	def clean
		self.subject = sanitize self.subject
	end

end
