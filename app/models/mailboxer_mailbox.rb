class MailboxerMailbox
  #this is used to filter mail by mailbox type, use the [] method rather than setting this directly.
  attr_accessor :type
  #the user/owner of this mailbox, set when initialized.
  attr_reader :messageable
  #creates a new Mailbox instance with the given user and optional type.
  
  def initialize(recipient, box = :all)
    @messageable = recipient
    @type = box
  end
  #sets the mailbox type to the symbol corresponding to the given val.
  def type=(val)
    @type = val.to_sym
  end
  
  def conversations(options = {})
    conv = MailboxerConversation.participant(@messageable)
    
    if options[:mailbox_type].present?
      case options[:mailbox_type]
        when 'inbox'
        conv = MailboxerConversation.inbox(@messageable)
        when 'sentbox'
        conv = MailboxerConversation.sentbox(@messageable)
        when 'trash'
        conv = MailboxerConversation.trash(@messageable)
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
  
  def mail(options = {})
    return MailboxerMail.where(options).receiver(@messageable)
  end
  
  def [](mailbox_type)
    self.type = mailbox_type
    return self
  end
  
  def <<(msg)
    return self.add(msg)
  end
  
  def add(msg)
    mail_msg = MailboxerMail.new
    mail_msg.mailboxer_message = msg
    mail_msg.read = (msg.sender.id == @messageable.id && msg.sender.class == @messageable.class)
    mail_msg.receiver = @messageable
    mail_msg.mailbox_type = @type.to_s unless @type == :all
    @messageable.mailboxer_mails << mail_msg
    return mail_msg
  end
  
  def empty_trash(options = {})
    return self.mail.trash(options).delete_all
  end
  
  def has_conversation?(conversation)
    return self.mail.conversation(converstaion).count!=0
  end
  
  def is_trashed?(conversation)
    return self.mail.trash.conversation(conversation).count!=0
  end
  def is_completely_trashed?(conversation)
    return self.mail.trash.conversation(conversation).count==self.mail.conversation(conversation).count
  end
  
end
