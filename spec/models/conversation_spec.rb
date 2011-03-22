require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Conversation do
  
  before do
    @entity1 = Factory(:user)
    @entity2 = Factory(:user)
    @mail1 = @entity1.send_message(@entity2,"Body","Subject")
    @mail2 = @entity2.reply_to_all(@mail1,"Reply body 1")
    @mail3 = @entity1.reply_to_all(@mail2,"Reply body 2")
    @mail4 = @entity2.reply_to_all(@mail3,"Reply body 3")
    @message1 = @mail1.message
    @message4 = @mail4.message
    @conversation = @message1.conversation
  end
  
  it "should have proper original message" do
    @conversation.original_message.should==@message1
  end
  
  it "should have proper originator (first sender)" do
    @conversation.originator.should==@entity1
  end
  
  it "should have proper last message" do
    @conversation.last_message.should==@message4
  end
  
  it "should have proper last sender" do
    @conversation.last_sender.should==@entity2
  end
  
  it "should have all conversation users" do   
    @conversation.get_recipients.count.should==2
    @conversation.get_recipients.count(@entity1).should==1
    @conversation.get_recipients.count(@entity2).should==1
  end
  
end
