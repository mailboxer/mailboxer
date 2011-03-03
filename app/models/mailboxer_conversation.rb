class MailboxerConversation < ActiveRecord::Base
  attr_reader :originator, :original_message, :last_sender, :last_message, :users
  has_many :mailboxer_messages
  #has_many :mailboxer_mails
  before_create :clean
  #looks like shit but isnt too bad
  #has_many :users, :through :messages, :source => :recipients, :uniq => true doesnt work due to recipients being a habtm association
  has_many :recipients, :class_name => 'User', :finder_sql => 
    'SELECT users.* FROM mailboxer_conversations 
    INNER JOIN mailboxer_messages ON mailboxer_conversations.id = mailboxer_messages.mailboxer_conversation_id 
    INNER JOIN mailboxer__recipients ON mailboxer__recipients.message_id = mailboxer_messages.id 
    INNER JOIN users ON messages_recipients.recipient_id = users.id
    WHERE conversations.id = #{self.id} GROUP BY users.id;'
  
  #originator of the conversation.
  def originator()
    @orignator = self.original_message.sender if @originator.nil?
    return @orignator
  end
  
  #first message of the conversation.
  def original_message()
    @original_message = self.mailboxer_messages.find(:first, :order => 'created_at') if @original_message.nil?
    return @original_message
  end
  
  #sender of the last message.
  def last_sender()
     @last_sender = self.last_message.sender if @last_sender.nil?
    return @last_sender
  end
  
  #last message in the conversation.
  def last_message()
    @last_message = self.mailboxer_messages.find(:first, :order => 'created_at DESC') if @last_message.nil?
    return @last_message
  end
  
  #all users involved in the conversation.
  def users()
    if(@users.nil?)
      @users = self.mailboxer_recipients.clone
      @users << self.originator unless @users.include?(self.originator) 
    end
    return @users
  end
    
  protected
  #[empty method]
  #
  #this gets called before_create. Implement this if you wish to clean out illegal content such as scripts or anything that will break layout. This is left empty because what is considered illegal content varies.
  def clean()
    return if(subject.nil?)
    #strip all illegal content here. (scripts, shit that will break layout, etc.)
  end
end
