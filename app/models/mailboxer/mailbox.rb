class Mailboxer::Mailbox
  attr_reader :messageable

  #Initializer method
  def initialize(messageable)
    @messageable = messageable
  end

  #Returns the notifications for the messageable
  def notifications(options = {})
    #:type => nil is a hack not to give Messages as Notifications
    notifs = Mailboxer::Notification.recipient(messageable).where(:type => nil).order(:created_at => :desc, :id => :desc)
    if options[:read] == false || options[:unread]
      notifs = notifs.unread
    end

    notifs
  end

  #Returns the conversations between messageable and other messageable
  def conversations_with(other_messageable)
    Mailboxer::Conversation.between(messageable, other_messageable)
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
    conv = get_conversations(options[:mailbox_type])

    if options[:read] == false || options[:unread]
      conv = conv.unread(messageable)
    end

    conv
  end

  #Returns the conversations in the inbox of messageable
  #
  #Same as conversations({:mailbox_type => 'inbox'})
  def inbox(options={})
    options = options.merge(:mailbox_type => 'inbox')
    conversations(options)
  end

  #Returns the conversations in the sentbox of messageable
  #
  #Same as conversations({:mailbox_type => 'sentbox'})
  def sentbox(options={})
    options = options.merge(:mailbox_type => 'sentbox')
    conversations(options)
  end

  #Returns the conversations in the trash of messageable
  #
  #Same as conversations({:mailbox_type => 'trash'})
  def trash(options={})
    options = options.merge(:mailbox_type => 'trash')
    conversations(options)
  end

  #Returns all the receipts of messageable, from Messages and Notifications
  def receipts(options = {})
    Mailboxer::Receipt.where(options).recipient(messageable)
  end

  #Deletes all the messages in the trash of messageable.
  def empty_trash(options = {})
    trash(options).each do |conversation|
      conversation.mark_as_deleted(messageable)
    end
  end

  #Returns if messageable is a participant of conversation
  def has_conversation?(conversation)
    conversation.is_participant?(messageable)
  end

  #Returns true if messageable has at least one trashed message of the conversation
  def is_trashed?(conversation)
    conversation.is_trashed?(messageable)
  end

  #Returns true if messageable has trashed all the messages of the conversation
  def is_completely_trashed?(conversation)
    conversation.is_completely_trashed?(messageable)
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
    when Mailboxer::Message, Mailboxer::Notification
      object.receipt_for(messageable)
    when Mailboxer::Conversation
      object.receipts_for(messageable)
    end
  end

  private

  def get_conversations(mailbox)
    case mailbox
    when 'inbox'
      Mailboxer::Conversation.inbox(messageable)
    when 'sentbox'
      Mailboxer::Conversation.sentbox(messageable)
    when 'trash'
      Mailboxer::Conversation.trash(messageable)
    when  'not_trash'
      Mailboxer::Conversation.not_trash(messageable)
    else
      Mailboxer::Conversation.participant(messageable)
    end
  end
end
