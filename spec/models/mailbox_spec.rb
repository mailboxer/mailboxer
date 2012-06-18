require 'spec_helper'

describe Mailbox do
  
  before do
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:user)
    @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
    @receipt2 = @entity2.reply_to_all(@receipt1,"Reply body 1")
    @receipt3 = @entity1.reply_to_all(@receipt2,"Reply body 2")
    @receipt4 = @entity2.reply_to_all(@receipt3,"Reply body 3")
    @message1 = @receipt1.notification
    @message4 = @receipt4.notification
    @conversation = @message1.conversation
  end  
  
  it "should return all conversations" do
    @conv2 = @entity1.send_message(@entity2,"Body","Subject").conversation
    @conv3 = @entity2.send_message(@entity1,"Body","Subject").conversation
    @conv4 =  @entity1.send_message(@entity2,"Body","Subject").conversation
    
    assert @entity1.mailbox.conversations
    
    @entity1.mailbox.conversations.to_a.count.should==4
        @entity1.mailbox.conversations.to_a.count(@conversation).should==1
        @entity1.mailbox.conversations.to_a.count(@conv2).should==1
        @entity1.mailbox.conversations.to_a.count(@conv3).should==1
        @entity1.mailbox.conversations.to_a.count(@conv4).should==1    
  end
  
  it "should return all mail" do 
    assert @entity1.mailbox.receipts
    @entity1.mailbox.receipts.count.should==4
    @entity1.mailbox.receipts[0].should==Receipt.recipient(@entity1).conversation(@conversation)[0]
    @entity1.mailbox.receipts[1].should==Receipt.recipient(@entity1).conversation(@conversation)[1]
    @entity1.mailbox.receipts[2].should==Receipt.recipient(@entity1).conversation(@conversation)[2]
    @entity1.mailbox.receipts[3].should==Receipt.recipient(@entity1).conversation(@conversation)[3]
    
    assert @entity2.mailbox.receipts
    @entity2.mailbox.receipts.count.should==4
    @entity2.mailbox.receipts[0].should==Receipt.recipient(@entity2).conversation(@conversation)[0]
    @entity2.mailbox.receipts[1].should==Receipt.recipient(@entity2).conversation(@conversation)[1]
    @entity2.mailbox.receipts[2].should==Receipt.recipient(@entity2).conversation(@conversation)[2]
    @entity2.mailbox.receipts[3].should==Receipt.recipient(@entity2).conversation(@conversation)[3]    
  end
  
  it "should return sentbox" do
    assert @entity1.mailbox.receipts.inbox
    @entity1.mailbox.receipts.sentbox.count.should==2
    @entity1.mailbox.receipts.sentbox[0].should==@receipt1
    @entity1.mailbox.receipts.sentbox[1].should==@receipt3
    
    assert @entity2.mailbox.receipts.inbox
    @entity2.mailbox.receipts.sentbox.count.should==2
    @entity2.mailbox.receipts.sentbox[0].should==@receipt2
    @entity2.mailbox.receipts.sentbox[1].should==@receipt4
  end
  
  it "should return inbox" do
    assert @entity1.mailbox.receipts.inbox
    @entity1.mailbox.receipts.inbox.count.should==2
    @entity1.mailbox.receipts.inbox[0].should==Receipt.recipient(@entity1).inbox.conversation(@conversation)[0]
    @entity1.mailbox.receipts.inbox[1].should==Receipt.recipient(@entity1).inbox.conversation(@conversation)[1]
    
    assert @entity2.mailbox.receipts.inbox
    @entity2.mailbox.receipts.inbox.count.should==2
    @entity2.mailbox.receipts.inbox[0].should==Receipt.recipient(@entity2).inbox.conversation(@conversation)[0]
    @entity2.mailbox.receipts.inbox[1].should==Receipt.recipient(@entity2).inbox.conversation(@conversation)[1]
  end

  it "should understand the read option" do
    @entity1.mailbox.inbox({:read => false}).count.should_not == 0
    @conversation.mark_as_read(@entity1)
    @entity1.mailbox.inbox({:read => false}).count.should == 0
  end
  
  it "should return trashed mails" do 
    @entity1.mailbox.receipts.move_to_trash
    
    assert @entity1.mailbox.receipts.trash
    @entity1.mailbox.receipts.trash.count.should==4
    @entity1.mailbox.receipts.trash[0].should==Receipt.recipient(@entity1).conversation(@conversation)[0]
    @entity1.mailbox.receipts.trash[1].should==Receipt.recipient(@entity1).conversation(@conversation)[1]
    @entity1.mailbox.receipts.trash[2].should==Receipt.recipient(@entity1).conversation(@conversation)[2]
    @entity1.mailbox.receipts.trash[3].should==Receipt.recipient(@entity1).conversation(@conversation)[3]
    
    assert @entity2.mailbox.receipts.trash
    @entity2.mailbox.receipts.trash.count.should==0    
  end
  
  it "should delete trashed mails (TODO)" do 
    @entity1.mailbox.receipts.move_to_trash
    #TODO
    #@entity1.mailbox.empty_trash
    
    assert @entity1.mailbox.receipts.trash
    #@entity1.mailbox.receipts.trash.count.should==0    
    
    assert @entity2.mailbox.receipts
    @entity2.mailbox.receipts.count.should==4
    
    assert @entity2.mailbox.receipts.trash
    @entity2.mailbox.receipts.trash.count.should==0    
  end
  
  
end
