require 'spec_helper'

describe "Mailboxer::Models::Messageable through User" do
  
  before do
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:user)
  end
  
  it "should have a mailbox" do
    assert @entity1.mailbox
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
  
  
  
  it "should be able to unread an owned Receipt (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @receipt.read.should==true
    @entity1.unread(@receipt)
    @receipt.read.should==false
  end
  
  it "should be able to read an owned Receipt (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @receipt.read.should==true
    @entity1.unread(@receipt)
    @entity1.read(@receipt)
    @receipt.read.should==true
  end
  
  it "should not be able to unread a not owned Receipt (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @receipt.read.should==true
    @entity2.unread(@receipt) #Should not change
    @receipt.read.should==true
  end
  
  it "should not be able to read a not owned Receipt (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @receipt.read.should==true
    @entity1.unread(@receipt) #From read to unread
    @entity2.read(@receipt) #Should not change
    @receipt.read.should==false
  end
  
  it "should be able to trash an owned Receipt" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @receipt.trashed.should==false
    @entity1.trash(@receipt)
    @receipt.trashed.should==true
  end
  
  it "should be able to untrash an owned Receipt" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @receipt.trashed.should==false
    @entity1.trash(@receipt)
    @entity1.untrash(@receipt)
    @receipt.trashed.should==false
  end
  
  it "should not be able to trash a not owned Receipt" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @receipt.trashed.should==false
    @entity2.trash(@receipt) #Should not change
    @receipt.trashed.should==false
  end
  
  it "should not be able to untrash a not owned Receipt" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @receipt.trashed.should==false
    @entity1.trash(@receipt) #From read to unread
    @entity2.untrash(@receipt) #Should not change
    @receipt.trashed.should==true
  end
  
  
  
  it "should be able to unread an owned Message (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    @receipt.read.should==true
    @entity1.unread(@message)
    @message.receipt_for(@entity1).first.read.should==false
  end
  
  it "should be able to read an owned Message (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    @receipt.read.should==true
    @entity1.unread(@message)
    @entity1.read(@message)
    @message.receipt_for(@entity1).first.read.should==true
  end
  
  it "should not be able to unread a not owned Message (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    @receipt.read.should==true
    @entity2.unread(@message) #Should not change
    @message.receipt_for(@entity1).first.read.should==true
  end
  
  it "should not be able to read a not owned Message (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    @receipt.read.should==true
    @entity1.unread(@message) #From read to unread
    @entity2.read(@message) #Should not change
    @message.receipt_for(@entity1).first.read.should==false
  end
  
  it "should be able to trash an owned Message" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    @receipt.trashed.should==false
    @entity1.trash(@message)
    @message.receipt_for(@entity1).first.trashed.should==true
  end
  
  it "should be able to untrash an owned Message" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    @receipt.trashed.should==false
    @entity1.trash(@message)
    @entity1.untrash(@message)
    @message.receipt_for(@entity1).first.trashed.should==false
  end
  
  it "should not be able to trash a not owned Message" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    @receipt.trashed.should==false
    @entity2.trash(@message) #Should not change
    @message.receipt_for(@entity1).first.trashed.should==false
  end
  
  it "should not be able to untrash a not owned Message" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @message = @receipt.message
    @receipt.trashed.should==false
    @entity1.trash(@message) #From read to unread
    @entity2.untrash(@message) #Should not change
    @message.receipt_for(@entity1).first.trashed.should==true
  end



  it "should be able to unread an owned Notification (mark as unread)" do
    @receipt = @entity1.notify("Subject","Body")
    @notification = @receipt.notification
    @receipt.read.should==false
    @entity1.read(@notification)
    @entity1.unread(@notification)
    @notification.receipt_for(@entity1).first.read.should==false
  end
  
  it "should be able to read an owned Notification (mark as read)" do
    @receipt = @entity1.notify("Subject","Body")
    @notification = @receipt.notification
    @receipt.read.should==false
    @entity1.read(@notification)
    @notification.receipt_for(@entity1).first.read.should==true
  end
  
  it "should not be able to unread a not owned Notification (mark as unread)" do
    @receipt = @entity1.notify("Subject","Body")
    @notification = @receipt.notification
    @receipt.read.should==false
    @entity1.read(@notification)
    @entity2.unread(@notification)
    @notification.receipt_for(@entity1).first.read.should==true
  end
  
  it "should not be able to read a not owned Notification (mark as read)" do
    @receipt = @entity1.notify("Subject","Body")
    @notification = @receipt.notification
    @receipt.read.should==false
    @entity2.read(@notification)
    @notification.receipt_for(@entity1).first.read.should==false
  end
  
  it "should be able to trash an owned Notification" do
    @receipt = @entity1.notify("Subject","Body")
    @notification = @receipt.notification
    @receipt.trashed.should==false
    @entity1.trash(@notification)
    @notification.receipt_for(@entity1).first.trashed.should==true
  end
  
  it "should be able to untrash an owned Notification" do
    @receipt = @entity1.notify("Subject","Body")
    @notification = @receipt.notification
    @receipt.trashed.should==false
    @entity1.trash(@notification)
    @entity1.untrash(@notification)
    @notification.receipt_for(@entity1).first.trashed.should==false
  end
  
  it "should not be able to trash a not owned Notification" do
    @receipt = @entity1.notify("Subject","Body")
    @notification = @receipt.notification
    @receipt.trashed.should==false
    @entity2.trash(@notification)
    @notification.receipt_for(@entity1).first.trashed.should==false
  end
  
  it "should not be able to untrash a not owned Notification" do
    @receipt = @entity1.notify("Subject","Body")
    @notification = @receipt.notification
    @receipt.trashed.should==false
    @entity1.trash(@notification)
    @entity2.untrash(@notification)
    @notification.receipt_for(@entity1).first.trashed.should==true
  end
  
  
  
  it "should be able to unread an owned Conversation (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    @receipt.read.should==true
    @entity1.unread(@conversation)
    @conversation.receipts_for(@entity1).first.read.should==false
  end
  
  it "should be able to read an owned Conversation (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    @receipt.read.should==true
    @entity1.unread(@conversation)
    @entity1.read(@conversation)
    @conversation.receipts_for(@entity1).first.read.should==true
  end
  
  it "should not be able to unread a not owned Conversation (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    @receipt.read.should==true
    @entity2.unread(@conversation)
    @conversation.receipts_for(@entity1).first.read.should==true
  end
  
  it "should not be able to read a not owned Conversation (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    @receipt.read.should==true
    @entity1.unread(@conversation)
    @entity2.read(@conversation)
    @conversation.receipts_for(@entity1).first.read.should==false
  end
  
  it "should be able to trash an owned Conversation" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    @receipt.trashed.should==false
    @entity1.trash(@conversation)
    @conversation.receipts_for(@entity1).first.trashed.should==true
  end
  
  it "should be able to untrash an owned Conversation" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    @receipt.trashed.should==false
    @entity1.trash(@conversation)
    @entity1.untrash(@conversation)
    @conversation.receipts_for(@entity1).first.trashed.should==false
  end
  
  it "should not be able to trash a not owned Conversation" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    @receipt.trashed.should==false
    @entity2.trash(@conversation)
    @conversation.receipts_for(@entity1).first.trashed.should==false
  end
  
  it "should not be able to untrash a not owned Conversation" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @conversation = @receipt.conversation
    @receipt.trashed.should==false
    @entity1.trash(@conversation)
    @entity2.untrash(@conversation)
    @conversation.receipts_for(@entity1).first.trashed.should==true
  end

  it "should be able to read attachment" do
    @receipt = @entity1.send_message(@entity2, "Body", "Subject", nil, File.open('spec/testfile.txt'))
    @conversation = @receipt.conversation
    @conversation.messages.first.attachment_identifier.should=='testfile.txt'
  end

end
