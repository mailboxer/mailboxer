require 'spec_helper'

describe Receipt do
  
  before do
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:user)
    @mail1 = @entity1.send_message(@entity2,"Body","Subject")   
  end
  
  it "should belong to a message" do
    assert @mail1.notification
  end
  
  it "should belong to a conversation" do
    assert @mail1.conversation    
  end
  
  it "should be able to be marked as unread" do
    @mail1.is_read.should==true
    @mail1.mark_as_unread
    @mail1.is_read.should==false
  end
  
  it "should be able to be marked as read" do
    @mail1.is_read.should==true
    @mail1.mark_as_unread
    @mail1.mark_as_read
    @mail1.is_read.should==true    
  end
  
  
end
