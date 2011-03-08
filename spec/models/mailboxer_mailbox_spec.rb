require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MailboxerMailbox do
  
  before do
    @entity1 = Factory(:user)
    @entity2 = Factory(:user)
    @mail1 = @entity1.send_message(@entity2,"Body","Subject")
    @mail2 = @entity2.reply_to_all(@mail1,"Reply body 1")
    @mail3 = @entity1.reply_to_all(@mail2,"Reply body 2")
    @mail4 = @entity2.reply_to_all(@mail3,"Reply body 3")
    @message1 = @mail1.mailboxer_message
    @message4 = @mail4.mailboxer_message
    @conversation = @message1.mailboxer_conversation
  end
  
  it "should return a correct sentbox for entity 1" do
    assert @entity1.mailbox.inbox
    @entity1.mailbox.sentbox.count.should==2
    @entity1.mailbox.sentbox[0].should==@mail1
    @entity1.mailbox.sentbox[1].should==@mail3
  end
  
  it "should return a correct sentbox for entity 2" do
    assert @entity2.mailbox.inbox
    @entity2.mailbox.sentbox.count.should==2
    @entity2.mailbox.sentbox[0].should==@mail2
    @entity2.mailbox.sentbox[1].should==@mail4
  end

  it "should return a correct inbox for entity 1" do
    assert @entity1.mailbox.inbox
    @entity1.mailbox.inbox.count.should==2
    @entity1.mailbox.inbox[0].should==MailboxerMail.receiver(@entity1).inbox.conversation(@conversation)[0]
    @entity1.mailbox.inbox[1].should==MailboxerMail.receiver(@entity1).inbox.conversation(@conversation)[1]
  end

  it "should return a correct inbox for entity 2" do
    assert @entity2.mailbox.inbox
    @entity2.mailbox.inbox.count.should==2
    @entity2.mailbox.inbox[0].should==MailboxerMail.receiver(@entity2).inbox.conversation(@conversation)[0]
    @entity2.mailbox.inbox[1].should==MailboxerMail.receiver(@entity2).inbox.conversation(@conversation)[1]
  end
  
  it "should be ok" do 
   
    @entity2.mailbox.mail.mark_all_as_read
    @entity1.mailbox.mail.mark_all_as_unread
    
    @entity1.mailbox.mail.unread.count.should==4
    @entity1.mailbox.mail.read.count.should==0
    @entity2.mailbox.mail.unread.count.should==0
    @entity2.mailbox.mail.read.count.should==4
        
  end



end
  