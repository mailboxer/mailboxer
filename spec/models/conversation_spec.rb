require 'spec_helper'

describe Conversation do
  
  before do
    @entity1 = Factory(:user)
    @entity2 = Factory(:user)
    @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
    @receipt2 = @entity2.reply_to_all(@receipt1,"Reply body 1")
    @receipt3 = @entity1.reply_to_all(@receipt2,"Reply body 2")
    @receipt4 = @entity2.reply_to_all(@receipt3,"Reply body 3")
    @message1 = @receipt1.notification
    @message4 = @receipt4.notification
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
    @conversation.recipients.count.should==2
    @conversation.recipients.count.should==2
    @conversation.recipients.count(@entity1).should==1
    @conversation.recipients.count(@entity2).should==1
  end
  
  it "should be able to be marked as read" do
    @conversation.move_to_trash(@entity1)
  end
  
  it "should be able to be marked as unread" do
    @conversation.move_to_trash(@entity1)
    @conversation.untrash(@entity1)
  end
  
end
