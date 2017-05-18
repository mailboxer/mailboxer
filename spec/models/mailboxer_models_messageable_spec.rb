require 'spec_helper'

describe "Mailboxer::Models::Messageable through User" do

  before do
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:user)
  end

  it "should have a mailbox" do
    assert @entity1.mailbox
  end

  it 'should return the inbox count' do
    expect(@entity1.unread_inbox_count).to eq 0
    @entity2.send_message(@entity1,"Body","Subject")
    @entity2.send_message(@entity1,"Body","Subject")
    expect(@entity1.unread_inbox_count).to eq 2
    @entity1.receipts.first.mark_as_read
    expect(@entity1.unread_inbox_count).to eq 1
    @entity2.send_message(@entity1,"Body","Subject")
    @entity2.send_message(@entity1,"Body","Subject")
    expect(@entity1.unread_inbox_count).to eq 3
  end

  it "should be able to send a message" do
    assert @entity1.send_message(@entity2,"Body","Subject")
  end

  it "should be able to reply to sender" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    assert @entity2.reply_to_sender(@receipt,"Reply body")
  end

  it "should be able to reply to all" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    assert @entity2.reply_to_all(@receipt,"Reply body")
  end

  it "should be able to unread an owned Mailboxer::Receipt (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    expect(@receipt.is_read).to eq true
    @entity1.mark_as_unread(@receipt)
    expect(@receipt.is_read).to eq false
  end

  it "should be able to read an owned Mailboxer::Receipt (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    expect(@receipt.is_read).to eq true
    @entity1.mark_as_unread(@receipt)
    @entity1.mark_as_read(@receipt)
    expect(@receipt.is_read).to eq true
  end

  it "should not be able to unread a not owned Mailboxer::Receipt (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    expect(@receipt.is_read).to eq true
    @entity2.mark_as_unread(@receipt) #Should not change
    expect(@receipt.is_read).to eq true
  end

  it "should not be able to read a not owned Mailboxer::Receipt (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    expect(@receipt.is_read).to eq true
    @entity1.mark_as_unread(@receipt) #From read to unread
    @entity2.mark_as_read(@receipt) #Should not change
    expect(@receipt.is_read).to eq false
  end

  it "should be able to trash an owned Mailboxer::Receipt" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    expect(@receipt.trashed).to eq false
    @entity1.trash(@receipt)
    expect(@receipt.trashed).to eq true
  end

  it "should be able to untrash an owned Mailboxer::Receipt" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    expect(@receipt.trashed).to eq false
    @entity1.trash(@receipt)
    @entity1.untrash(@receipt)
    expect(@receipt.trashed).to eq false
  end

  it "should not be able to trash a not owned Mailboxer::Receipt" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    expect(@receipt.trashed).to eq false
    @entity2.trash(@receipt) #Should not change
    expect(@receipt.trashed).to eq false
  end

  it "should not be able to untrash a not owned Mailboxer::Receipt" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    expect(@receipt.trashed).to eq false
    @entity1.trash(@receipt) #From read to unread
    @entity2.untrash(@receipt) #Should not change
    expect(@receipt.trashed).to eq true
  end



  it "should be able to unread an owned Message (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    expect(@receipt.is_read).to eq true
    @entity1.mark_as_unread(@message)
    expect(@message.receipt_for(@entity1).first.is_read).to eq false
  end

  it "should be able to read an owned Message (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    expect(@receipt.is_read).to eq true
    @entity1.mark_as_unread(@message)
    @entity1.mark_as_read(@message)
    expect(@message.receipt_for(@entity1).first.is_read).to eq true
  end

  it "should not be able to unread a not owned Message (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    expect(@receipt.is_read).to eq true
    @entity2.mark_as_unread(@message) #Should not change
    expect(@message.receipt_for(@entity1).first.is_read).to eq true
  end

  it "should not be able to read a not owned Message (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    expect(@receipt.is_read).to eq true
    @entity1.mark_as_unread(@message) #From read to unread
    @entity2.mark_as_read(@message) #Should not change
    expect(@message.receipt_for(@entity1).first.is_read).to eq false
  end

  it "should be able to trash an owned Message" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    expect(@receipt.trashed).to eq false
    @entity1.trash(@message)
    expect(@message.receipt_for(@entity1).first.trashed).to eq true
  end

  it "should be able to untrash an owned Message" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    expect(@receipt.trashed).to eq false
    @entity1.trash(@message)
    @entity1.untrash(@message)
    expect(@message.receipt_for(@entity1).first.trashed).to eq false
  end

  it "should not be able to trash a not owned Message" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    expect(@receipt.trashed).to eq false
    @entity2.trash(@message) #Should not change
    expect(@message.receipt_for(@entity1).first.trashed).to eq false
  end

  it "should not be able to untrash a not owned Message" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    expect(@receipt.trashed).to eq false
    @entity1.trash(@message) #From read to unread
    @entity2.untrash(@message) #Should not change
    expect(@message.receipt_for(@entity1).first.trashed).to eq true
  end



  it "should be able to unread an owned Notification (mark as unread)" do
    @receipt = @entity1.send(Mailboxer.notify_method, "Subject", "Body")
    @notification = @receipt.notification
    expect(@receipt.is_read).to eq false
    @entity1.mark_as_read(@notification)
    @entity1.mark_as_unread(@notification)
    expect(@notification.receipt_for(@entity1).first.is_read).to eq false
  end

  it "should be able to read an owned Notification (mark as read)" do
    @receipt = @entity1.send(Mailboxer.notify_method, "Subject", "Body")
    @notification = @receipt.notification
    expect(@receipt.is_read).to eq false
    @entity1.mark_as_read(@notification)
    expect(@notification.receipt_for(@entity1).first.is_read).to eq true
  end

  it "should not be able to unread a not owned Notification (mark as unread)" do
    @receipt = @entity1.send(Mailboxer.notify_method, "Subject", "Body")
    @notification = @receipt.notification
    expect(@receipt.is_read).to eq false
    @entity1.mark_as_read(@notification)
    @entity2.mark_as_unread(@notification)
    expect(@notification.receipt_for(@entity1).first.is_read).to eq true
  end

  it "should not be able to read a not owned Notification (mark as read)" do
    @receipt = @entity1.send(Mailboxer.notify_method, "Subject", "Body")
    @notification = @receipt.notification
    expect(@receipt.is_read).to eq false
    @entity2.mark_as_read(@notification)
    expect(@notification.receipt_for(@entity1).first.is_read).to eq false
  end

  it "should be able to trash an owned Notification" do
    @receipt = @entity1.send(Mailboxer.notify_method, "Subject", "Body")
    @notification = @receipt.notification
    expect(@receipt.trashed).to eq false
    @entity1.trash(@notification)
    expect(@notification.receipt_for(@entity1).first.trashed).to eq true
  end

  it "should be able to untrash an owned Notification" do
    @receipt = @entity1.send(Mailboxer.notify_method, "Subject", "Body")
    @notification = @receipt.notification
    expect(@receipt.trashed).to eq false
    @entity1.trash(@notification)
    @entity1.untrash(@notification)
    expect(@notification.receipt_for(@entity1).first.trashed).to eq false
  end

  it "should not be able to trash a not owned Notification" do
    @receipt = @entity1.send(Mailboxer.notify_method, "Subject", "Body")
    @notification = @receipt.notification
    expect(@receipt.trashed).to eq false
    @entity2.trash(@notification)
    expect(@notification.receipt_for(@entity1).first.trashed).to eq false
  end

  it "should not be able to untrash a not owned Notification" do
    @receipt = @entity1.send(Mailboxer.notify_method, "Subject", "Body")
    @notification = @receipt.notification
    expect(@receipt.trashed).to eq false
    @entity1.trash(@notification)
    @entity2.untrash(@notification)
    expect(@notification.receipt_for(@entity1).first.trashed).to eq true
  end



  it "should be able to unread an owned Conversation (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    expect(@receipt.is_read).to eq true
    @entity1.mark_as_unread(@conversation)
    expect(@conversation.receipts_for(@entity1).first.is_read).to eq false
  end

  it "should be able to read an owned Conversation (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    expect(@receipt.is_read).to eq true
    @entity1.mark_as_unread(@conversation)
    @entity1.mark_as_read(@conversation)
    expect(@conversation.receipts_for(@entity1).first.is_read).to eq true
  end

  it "should not be able to unread a not owned Conversation (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    expect(@receipt.is_read).to eq true
    @entity2.mark_as_unread(@conversation)
    expect(@conversation.receipts_for(@entity1).first.is_read).to eq true
  end

  it "should not be able to read a not owned Conversation (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    expect(@receipt.is_read).to eq true
    @entity1.mark_as_unread(@conversation)
    @entity2.mark_as_read(@conversation)
    expect(@conversation.receipts_for(@entity1).first.is_read).to eq false
  end

  it "should be able to trash an owned Conversation" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    expect(@receipt.trashed).to eq false
    @entity1.trash(@conversation)
    expect(@conversation.receipts_for(@entity1).first.trashed).to eq true
  end

  it "should be able to untrash an owned Conversation" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    expect(@receipt.trashed).to eq false
    @entity1.trash(@conversation)
    @entity1.untrash(@conversation)
    expect(@conversation.receipts_for(@entity1).first.trashed).to eq false
  end

  it "should not be able to trash a not owned Conversation" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    expect(@receipt.trashed).to eq false
    @entity2.trash(@conversation)
    expect(@conversation.receipts_for(@entity1).first.trashed).to eq false
  end

  it "should not be able to untrash a not owned Conversation" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    expect(@receipt.trashed).to eq false
    @entity1.trash(@conversation)
    @entity2.untrash(@conversation)
    expect(@conversation.receipts_for(@entity1).first.trashed).to eq true
  end

  it "should be able to read attachment" do
    @receipt = @entity1.send_message(@entity2, "Body", "Subject", nil, File.open('spec/testfile.txt'))
    @conversation = @receipt.conversation
    expect(@conversation.messages.first.attachment_identifier).to eq 'testfile.txt'
  end

  it "should be the same message time as passed" do
    message_time = 5.days.ago
    receipt = @entity1.send_message(@entity2, "Body", "Subject", nil, nil, message_time)
    # We're going to compare the string representation, because ActiveSupport::TimeWithZone
    # has microsecond precision in ruby, but some databases don't support this level of precision.
    expected = message_time.utc.to_s
    expect(receipt.message.created_at.utc.to_s).to eq expected
    expect(receipt.message.updated_at.utc.to_s).to eq expected
    expect(receipt.message.conversation.created_at.utc.to_s).to eq expected
    expect(receipt.message.conversation.updated_at.utc.to_s).to eq expected
  end

end
