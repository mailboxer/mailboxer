require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MailboxerMail do
  
  before do
    @entity1 = Factory(:user)
    @entity2 = Factory(:user)
    @mail1 = @entity1.send_message(@entity2,"Body","Subject")   
  end
  
  it "should belong to a message" do
    assert @mail1.mailboxer_message
  end
  
  it "should belong to a conversation" do
    assert @mail1.mailboxer_conversation    
  end
  
  it "should be able to be marked as unread" do
    @mail1.read.should==true
    @mail1.mark_as_unread
    @mail1.read.should==false
  end
  
  it "should be able to be marked as read" do
    @mail1.read.should==true
    @mail1.mark_as_unread
    @mail1.mark_as_read
    @mail1.read.should==true    
  end
  
  
end
