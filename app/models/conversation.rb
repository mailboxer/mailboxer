class Conversation < ActiveRecord::Base
  attr_accessible :subject if Rails::VERSION::MAJOR == 3

  has_many :messages, :dependent => :destroy
  has_many :receipts, :through => :messages

  validates_presence_of :subject

  before_validation :clean

  scope :participant, lambda {|participant|
    select('DISTINCT conversations.*').
      where('notifications.type'=> Message.name).
      order("conversations.updated_at DESC").
      joins(:receipts).merge(Receipt.recipient(participant))
  }
  scope :inbox, lambda {|participant|
    participant(participant).merge(Receipt.inbox.not_trash)
  }
  scope :sentbox, lambda {|participant|
    participant(participant).merge(Receipt.sentbox.not_trash)
  }
  scope :trash, lambda {|participant|
    participant(participant).merge(Receipt.trash)
  }
  scope :unread,  lambda {|participant|
    participant(participant).merge(Receipt.is_unread)
  }
  scope :not_trash,  lambda {|participant|
    participant(participant).merge(Receipt.not_trash)
  }

  #Mark the conversation as read for one of the participants
  def mark_as_read(participant)
    return if participant.nil?
    self.receipts_for(participant).mark_as_read
  end

  #Mark the conversation as unread for one of the participants
  def mark_as_unread(participant)
    return if participant.nil?
    self.receipts_for(participant).mark_as_unread
  end

  #Move the conversation to the trash for one of the participants
  def move_to_trash(participant)
    return if participant.nil?
    self.receipts_for(participant).move_to_trash
  end

  #Takes the conversation out of the trash for one of the participants
  def untrash(participant)
    return if participant.nil?
    self.receipts_for(participant).untrash
  end

  #Returns an array of participants
  def recipients
    if self.last_message
      recps = self.last_message.recipients
      recps = recps.is_a?(Array) ? recps : [recps]
      recps
    else
      []
    end
  end

  #Returns an array of participants
  def participants
    recipients
  end

  #Originator of the conversation.
  def originator
    @originator ||= self.original_message.sender
  end

  #First message of the conversation.
  def original_message
    @original_message ||= self.messages.find(:first, :order => 'created_at')
  end

  #Sender of the last message.
  def last_sender
    @last_sender ||= self.last_message.sender
  end

  #Last message in the conversation.
  def last_message
    @last_message ||= self.messages.find(:first, :order => 'created_at DESC')
  end

  #Returns the receipts of the conversation for one participants
  def receipts_for(participant)
    Receipt.conversation(self).recipient(participant)
  end

  #Returns the number of messages of the conversation
  def count_messages
    Message.conversation(self).count
  end

  #Returns true if the messageable is a participant of the conversation
  def is_participant?(participant)
    return false if participant.nil?
    self.receipts_for(participant).count != 0
  end

  #Returns true if the participant has at least one trashed message of the conversation
  def is_trashed?(participant)
    return false if participant.nil?
    self.receipts_for(participant).trash.count != 0
  end

  #Returns true if the participant has trashed all the messages of the conversation
  def is_completely_trashed?(participant)
    return false if participant.nil?
    self.receipts_for(participant).trash.count == self.receipts_for(participant).count
  end

  def is_read?(participant)
    !self.is_unread?(participant)
  end

  #Returns true if the participant has at least one unread message of the conversation
  def is_unread?(participant)
    return false if participant.nil?
    self.receipts_for(participant).not_trash.is_unread.count != 0
  end

  protected

  include ActionView::Helpers::SanitizeHelper

  #Use the default sanitize to clean the conversation subject
  def clean
    self.subject = sanitize self.subject
  end
end
