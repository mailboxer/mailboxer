require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Mailboxer::Models::Messageable through User" do
  
  before do
    @entity1 = Factory(:user)
    @entity2 = Factory(:user)
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
  
  it "should be able to reply to conversation (TODO)" do
    #TODO
  end
  
  it "should be able to unread an owned mail (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @receipt.read.should==true
    @entity1.unread_message(@receipt)
    @receipt.read.should==false
  end
  
  it "should be able to read an owned mail (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @receipt.read.should==true
    @entity1.unread_message(@receipt)
    @entity1.read_message(@receipt)
    @receipt.read.should==true
  end
  
  it "should be able to unread anot owned mail (mark as unread)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @receipt.read.should==true
    @entity2.unread_message(@receipt) #Should not change
    @receipt.read.should==true
  end
  
  it "should be able to read a not owned mail (mark as read)" do
    @receipt = @entity1.send_message(@entity2,"Body","Subject")
    @receipt.read.should==true
    @entity1.unread_message(@receipt) #From read to unread
    @entity2.read_message(@receipt) #Should not change
    @receipt.read.should==false
  end
  
=begin  
  it "should be able to read owned mails of a conversation" do
    @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
    @receipt2 = @entity2.reply_to_all(@receipt1,"Reply body 1")
    @receipt3 = @entity1.reply_to_all(@receipt2,"Reply body 2")
    @receipt4 = @entity2.reply_to_all(@receipt3,"Reply body 3")
    @message1 = @receipt1.message
    @conversation = @message1.conversation
    
    @conversation.mark_as_read(@entity1)
    
    @receipts = @conversation.receipts(@entity1)
    
    @receipts.each do |mail|
      mail.read.should==true
    end    
  end
  
  it "should not be able to read not owned mails of a conversation" do
    @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
    @receipt2 = @entity2.reply_to_all(@receipt1,"Reply body 1")
    @receipt3 = @entity1.reply_to_all(@receipt2,"Reply body 2")
    @receipt4 = @entity2.reply_to_all(@receipt3,"Reply body 3")
    @message1 = @receipt1.message
    @conversation = @message1.conversation
    
    @conversation.mark_as_read(@entity2)
    
    @receipts = @conversation.receipts(@entity1)
    @receipts_total = @conversation.receipts
    
    unread_mails = 0
    
    @receipts.each do |mail|
      unread_mails+=1 if !mail.read
    end
    
    unread_mails.should==2
    
    
    
  end
=end  
  
  
end
