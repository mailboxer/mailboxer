class MailboxerConversation < ActiveRecord::Base
  attr_reader :originator, :original_message, :last_sender, :last_message, :users
  has_many :mailboxer_messages
  has_many :mailboxer_mails, :through => :mailboxer_messages
  before_create :clean
  scope :participant, lambda {|participant|
    joins(:mailboxer_messages,:mailboxer_mails).select('DISTINCT mailboxer_conversations.*').where('mailboxer_mails.receiver_id' => participant.id,'mailboxer_mails.receiver_type' => participant.class.to_s)    
  }
  
  #originator of the conversation.
  def originator
    @orignator = self.original_message.sender if @originator.nil?
    return @orignator
  end
  
  #first message of the conversation.
  def original_message
    @original_message = self.mailboxer_messages.find(:first, :order => 'created_at') if @original_message.nil?
    return @original_message
  end
  
  #sender of the last message.
  def last_sender
    @last_sender = self.last_message.sender if @last_sender.nil?
    return @last_sender
  end
  
  #last message in the conversation.
  def last_message
    @last_message = self.mailboxer_messages.find(:first, :order => 'created_at DESC') if @last_message.nil?
    return @last_message
  end
  
  def mails(participant=nil)
    return MailboxerMail.conversation(self).receiver(participant) if participant
    return MailboxerMail.conversation(self)
  end
  
  #all users involved in the conversation.
  def recipients
    return last_message.get_recipients
  end
  
  def get_recipients
    return self.recipients
  end
  
  def messages
    self.mailboxer_messages
  end
  
  def count_messages
    return MailboxerMessage.conversation(self).count
  end
  
  protected
  #[empty method]
  #
  #this gets called before_create. Implement this if you wish to clean out illegal content such as scripts or anything that will break layout. This is left empty because what is considered illegal content varies.
  def clean
    return if subject.nil?
    #strip all illegal content here. (scripts, shit that will break layout, etc.)
  end
end
