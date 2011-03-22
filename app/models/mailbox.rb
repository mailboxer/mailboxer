class Mailbox
  attr_accessor :type
  attr_reader :messageable
  
  def initialize(recipient, box = :all)
    @messageable = recipient
    @type = box
  end
  #sets the mailbox type to the symbol corresponding to the given val.
  def type=(val)
    @type = val.to_sym
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
  
  def [](mailbox_type)
    self.type = mailbox_type
    return self
  end
  
  def <<(msg)
    return self.add(msg)
  end
  
  def add(msg)
    msg_receipt = Receipt.new
    msg_receipt.message = msg
    msg_receipt.read = (msg.sender.id == @messageable.id && msg.sender.class == @messageable.class)
    msg_receipt.receiver = @messageable
    msg_receipt.mailbox_type = @type.to_s unless @type == :all
    @messageable.receipts << msg_receipt
    return msg_receipt
  end
  
  def empty_trash(options = {})
    return false
  end
  
  def has_conversation?(conversation)
    return self.receipts.conversation(converstaion).count!=0
  end
  
  def is_trashed?(conversation)
    return self.receipts.trash.conversation(conversation).count!=0
  end
  def is_completely_trashed?(conversation)
    return self.receipts.trash.conversation(conversation).count==self.receipts.conversation(conversation).count
  end
  
end
