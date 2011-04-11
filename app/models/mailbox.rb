class Mailbox
	attr_accessor :type
	attr_reader :messageable
	def initialize(recipient, box = :all)
		@messageable = recipient
	end
	
	def notifications(options = {})
	  
	end

	def conversations(options = {})
		conv = Conversation.participant(@messageable)

		if options[:mailbox_type].present?
			case options[:mailbox_type]
			when 'inbox'
				conv = Conversation.inbox(@messageable)
			when 'sentbox'
				conv = Conversation.sentbox(@messageable)
			when 'trash'
				conv = Conversation.trash(@messageable)
			end
		end

		if (options[:read].present? and options[:read]==false) or (options[:unread].present? and options[:unread]==true)
		conv = conv.unread(@messageable)
		end
		
		return conv.uniq
	end

	def inbox(options={})
		options = options.merge(:mailbox_type => 'inbox')
		return self.conversations(options)
	end

	def sentbox(options={})
		options = options.merge(:mailbox_type => 'sentbox')
		return self.conversations(options)
	end

	def trash(options={})
		options = options.merge(:mailbox_type => 'trash')
		return self.conversations(options)
	end

	def receipts(options = {})
		return Receipt.where(options).receiver(@messageable)
	end

	def empty_trash(options = {})
	  #TODO
		return false
	end

	def has_conversation?(conversation)
		return conversation.is_participant?(@messageable)
	end

	def is_trashed?(conversation)
		return conversation.is_trashed?(@messageable)
	end

	def is_completely_trashed?(conversation)
		return conversation.is_completely_trashed?(@messageable)
	end

end
