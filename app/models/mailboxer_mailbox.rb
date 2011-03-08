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

  def mail(options = {})
    return MailboxerMail.where(options).receiver(@messageable)
  end
  
  def inbox(options = {})
    return self.mail(options).inbox
  end
  
  def sentbox(options = {})
    return self.mail(options).sentbox
  end
  
  def trash(options = {})
    return self.mail(options).trash
  end


  def latest_mail(options = {})
    return only_latest(mail(options))
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
    return self.trash(options).delete_all
  end

  def has_conversation?(conversation)
    return self.mail.conversation(converstaion).count!=0
  end
  
  
  private
  
  def only_latest(mail)
    convos = []
    latest = []
    mail.each do |m|
      next if(convos.include?(m.mailboxer_conversation_id))
      convos << m.mailboxer_conversation_id
      latest << m
    end
    return latest
  end
end
