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
    @mail = @entity1.send_message(@entity2,"Body","Subject")
    assert @entity2.reply_to_sender(@mail,"Reply body")
  end
  
  it "should be able to reply to all" do
    @mail = @entity1.send_message(@entity2,"Body","Subject")
    assert @entity2.reply_to_all(@mail,"Reply body")    
  end
  
  it "should be able to reply to conversation (TODO)" do
    #TODO
  end
  
  it "should be able to unread an owned mail (mark as unread)" do
    @mail = @entity1.send_message(@entity2,"Body","Subject")
    @mail.read.should==true
    @entity1.unread_mail(@mail)
    @mail.read.should==false
  end
  
  it "should be able to read an owned mail (mark as read)" do
    @mail = @entity1.send_message(@entity2,"Body","Subject")
    @mail.read.should==true
    @entity1.unread_mail(@mail)
    @entity1.read_mail(@mail)
    @mail.read.should==true
  end
  
  it "should be able to unread anot owned mail (mark as unread)" do
    @mail = @entity1.send_message(@entity2,"Body","Subject")
    @mail.read.should==true
    @entity2.unread_mail(@mail) #Should not change
    @mail.read.should==true
  end
  
  it "should be able to read a not owned mail (mark as read)" do
    @mail = @entity1.send_message(@entity2,"Body","Subject")
    @mail.read.should==true
    @entity1.unread_mail(@mail) #From read to unread
    @entity2.read_mail(@mail) #Should not change
    @mail.read.should==false
  end
  
  it "should be able to read owned mails of a conversation" do
    @mail1 = @entity1.send_message(@entity2,"Body","Subject")
    @mail2 = @entity2.reply_to_all(@mail1,"Reply body 1")
    @mail3 = @entity1.reply_to_all(@mail2,"Reply body 2")
    @mail4 = @entity2.reply_to_all(@mail3,"Reply body 3")
    @message1 = @mail1.message
    @conversation = @message1.conversation
    
    @entity1.read_conversation(@conversation)
    
    @mails = @conversation.mails.receiver(@entity1)
    
    @mails.each do |mail|
      mail.read.should==true
    end
    
  end
  
  it "should not be able to read not owned mails of a conversation" do
    @mail1 = @entity1.send_message(@entity2,"Body","Subject")
    @mail2 = @entity2.reply_to_all(@mail1,"Reply body 1")
    @mail3 = @entity1.reply_to_all(@mail2,"Reply body 2")
    @mail4 = @entity2.reply_to_all(@mail3,"Reply body 3")
    @message1 = @mail1.message
    @conversation = @message1.conversation
    
    @entity2.read_conversation(@conversation)
    
    @mails = @conversation.mails.receiver(@entity1)
    @mails_total = @conversation.mails
    
    unread_mails = 0
    
    @mails.each do |mail|
      unread_mails+=1 if !mail.read
    end
    
    unread_mails.should==2
    
    
    
  end
  
  
  
end
