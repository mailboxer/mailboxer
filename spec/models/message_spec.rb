require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  
  before do
    @entity1 = Factory(:user)
    @entity2 = Factory(:user)
    @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
    @receipt2 = @entity2.reply_to_all(@receipt1,"Reply body 1")
    @receipt3 = @entity1.reply_to_all(@receipt2,"Reply body 2")
    @receipt4 = @entity2.reply_to_all(@receipt3,"Reply body 3")
    @message1 = @receipt1.message
    @message4 = @receipt4.message
    @conversation = @message1.conversation
  end  
  
  it "should have right recipients" do
  	@receipt1.message.recipients.count.should==2
  	@receipt2.message.recipients.count.should==2
  	@receipt3.message.recipients.count.should==2
  	@receipt4.message.recipients.count.should==2      
  end
    
end
