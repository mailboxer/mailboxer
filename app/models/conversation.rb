class Conversation < ActiveRecord::Base
	attr_reader :originator, :original_message, :last_sender, :last_message
	has_many :messages
	has_many :receipts, :through => :messages

	validates_presence_of :subject

	before_validation :clean

	#  before_create :clean
	scope :participant, lambda {|participant|
    joins(:receipts).select('DISTINCT conversations.*').where('receipts.receiver_id' => participant.id,'receipts.receiver_type' => participant.class.to_s).order("conversations.updated_at DESC")
  }
	scope :inbox, lambda {|participant|
    joins(:receipts).select('DISTINCT conversations.*').where('receipts.receiver_id' => participant.id,'receipts.receiver_type' => participant.class.to_s, 'receipts.mailbox_type' => 'inbox','receipts.trashed' => false).order("conversations.updated_at DESC")
  }
	scope :sentbox, lambda {|participant|
    joins(:receipts).select('DISTINCT conversations.*').where('receipts.receiver_id' => participant.id,'receipts.receiver_type' => participant.class.to_s, 'receipts.mailbox_type' => 'sentbox','receipts.trashed' => false).order("conversations.updated_at DESC")
  }
	scope :trash, lambda {|participant|
    joins(:receipts).select('DISTINCT conversations.*').where('receipts.receiver_id' => participant.id,'receipts.receiver_type' => participant.class.to_s,'receipts.trashed' => true).order("conversations.updated_at DESC")
  }
	scope :unread,  lambda {|participant|
    joins(:receipts).select('DISTINCT conversations.*').where('receipts.receiver_id' => participant.id,'receipts.receiver_type' => participant.class.to_s,'receipts.read' => false).order("conversations.updated_at DESC")
  }
	class << self
		def total
			count('DISTINCT conversations.id')
		end
	end

	def mark_as_read(participant)
		return if participant.nil?
		return self.receipts_for(participant).mark_as_read
	end

	def mark_as_unread(participant)
		return if participant.nil?
		return self.receipts_for(participant).mark_as_unread
	end

	def move_to_trash(participant)
		return if participant.nil?
		return self.receipts_for(participant).move_to_trash
	end

	def untrash(participant)
		return if participant.nil?
		return self.receipts_for(participant).untrash
	end

	def recipients
		if self.last_message
			recps = self.last_message.recipients
			recps = recps.is_a?(Array) ? recps : [recps]
		return recps
		end
		return []
	end

	#originator of the conversation.
	def originator
		@orignator = self.original_message.sender if @originator.nil?
		return @orignator
	end

	#first message of the conversation.
	def original_message
		@original_message = self.messages.find(:first, :order => 'created_at') if @original_message.nil?
		return @original_message
	end

	#sender of the last message.
	def last_sender
		@last_sender = self.last_message.sender if @last_sender.nil?
		return @last_sender
	end

	#last message in the conversation.
	def last_message
		@last_message = self.messages.find(:first, :order => 'created_at DESC') if @last_message.nil?
		return @last_message
	end

	def receipts_for(participant)
		return Receipt.conversation(self).receiver(participant)
	end

	def count_messages
		return Message.conversation(self).count
	end

	def is_participant?(participant)
		return false if participant.nil?
		return self.receipts_for(participant).count != 0
	end

	def is_trashed?(participant)
		return false if participant.nil?
		return self.receipts_for(participant).trash.count!=0
	end

	def is_completely_trashed?(participant)
		return false if participant.nil?
		return self.receipts_for(participant).trash.count==self.receipts(participant).count
	end

	def is_unread?(participant)
		return false if participant.nil?
		return self.receipts_for(participant).unread.count!=0
	end
	#  protected
	#  #[empty method]
	#  #
	#  #this gets called before_create. Implement this if you wish to clean out illegal content such as scripts or anything that will break layout. This is left empty because what is considered illegal content varies.
	#  def clean
	#    return if subject.nil?
	#    #strip all illegal content here. (scripts, shit that will break layout, etc.)
	#  end

	protected

	include ActionView::Helpers::SanitizeHelper

	def clean
		self.subject = sanitize self.subject
	end

end
