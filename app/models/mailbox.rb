class Mailbox
  attr_accessor :type
  attr_reader :messageable
  #Initializer method
  def initialize(messageable)
    @messageable = messageable
  end

  #Returns the notifications for the messageable
  def notifications(options = {})
    #:type => nil is a hack not to give Messages as Notifications
    notifs = Notification.recipient(@messageable).where(:type => nil).order("notifications.created_at DESC")
    if (options[:read].present? and options[:read]==false) or (options[:unread].present? and options[:unread]==true)
      notifs = notifs.unread
    end
    return notifs 
  end

  #Returns the conversations for the messageable
  #
  #Options
  #
  #* :mailbox_type
  #  * "inbox"
  #  * "sentbox"
  #  * "trash"
  #
  #* :read=false
  #* :unread=true
  #
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

    if (options.has_key?(:read) && options[:read]==false) || (options.has_key?(:unread) && options[:unread]==true)
      conv = conv.unread(@messageable)
    end

    return conv
  end

  #Returns the conversations in the inbox of messageable
  #
  #Same as conversations({:mailbox_type => 'inbox'})
  def inbox(options={})
    options = options.merge(:mailbox_type => 'inbox')
    return self.conversations(options)
  end

  #Returns the conversations in the sentbox of messageable
  #
  #Same as conversations({:mailbox_type => 'sentbox'})
  def sentbox(options={})
    options = options.merge(:mailbox_type => 'sentbox')
    return self.conversations(options)
  end

  #Returns the conversations in the trash of messageable
  #
  #Same as conversations({:mailbox_type => 'trash'})
  def trash(options={})
    options = options.merge(:mailbox_type => 'trash')
    return self.conversations(options)
  end

  #Returns all the receipts of messageable, from Messages and Notifications
  def receipts(options = {})
    return Receipt.where(options).recipient(@messageable)
  end

  #Deletes all the messages in the trash of messageable. NOT IMPLEMENTED.
  def empty_trash(options = {})
    #TODO
    return false
  end

  #Returns if messageable is a participant of conversation
  def has_conversation?(conversation)
    return conversation.is_participant?(@messageable)
  end

  #Returns true if messageable has at least one trashed message of the conversation
  def is_trashed?(conversation)
    return conversation.is_trashed?(@messageable)
  end

  #Returns true if messageable has trashed all the messages of the conversation
  def is_completely_trashed?(conversation)
    return conversation.is_completely_trashed?(@messageable)
  end

  #Returns the receipts of object for messageable as a ActiveRecord::Relation
  #
  #Object can be:
  #* A Message
  #* A Notification
  #* A Conversation
  #
  #If object isn't one of the above, a nil will be returned
  def receipts_for(object)
    case object
    when Message, Notification
      return object.receipt_for(@messageable)
    when Conversation
      return object.receipts_for(@messageable)
    else
    return nil
    end
  end

end
