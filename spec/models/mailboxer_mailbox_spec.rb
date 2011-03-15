require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MailboxerMailbox do
  
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
    assert @entity1.mailbox.mail
    @entity1.mailbox.mail.count.should==4
    @entity1.mailbox.mail[0].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[0]
    @entity1.mailbox.mail[1].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[1]
    @entity1.mailbox.mail[2].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[2]
    @entity1.mailbox.mail[3].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[3]
    
    assert @entity2.mailbox.mail
    @entity2.mailbox.mail.count.should==4
    @entity2.mailbox.mail[0].should==MailboxerMail.receiver(@entity2).conversation(@conversation)[0]
    @entity2.mailbox.mail[1].should==MailboxerMail.receiver(@entity2).conversation(@conversation)[1]
    @entity2.mailbox.mail[2].should==MailboxerMail.receiver(@entity2).conversation(@conversation)[2]
    @entity2.mailbox.mail[3].should==MailboxerMail.receiver(@entity2).conversation(@conversation)[3]    
  end
  
  it "should return sentbox" do
    assert @entity1.mailbox.mail.inbox
    @entity1.mailbox.mail.sentbox.count.should==2
    @entity1.mailbox.mail.sentbox[0].should==@mail1
    @entity1.mailbox.mail.sentbox[1].should==@mail3
    
    assert @entity2.mailbox.mail.inbox
    @entity2.mailbox.mail.sentbox.count.should==2
    @entity2.mailbox.mail.sentbox[0].should==@mail2
    @entity2.mailbox.mail.sentbox[1].should==@mail4
  end
  
  it "should return inbox" do
    assert @entity1.mailbox.mail.inbox
    @entity1.mailbox.mail.inbox.count.should==2
    @entity1.mailbox.mail.inbox[0].should==MailboxerMail.receiver(@entity1).inbox.conversation(@conversation)[0]
    @entity1.mailbox.mail.inbox[1].should==MailboxerMail.receiver(@entity1).inbox.conversation(@conversation)[1]
    
    assert @entity2.mailbox.mail.inbox
    @entity2.mailbox.mail.inbox.count.should==2
    @entity2.mailbox.mail.inbox[0].should==MailboxerMail.receiver(@entity2).inbox.conversation(@conversation)[0]
    @entity2.mailbox.mail.inbox[1].should==MailboxerMail.receiver(@entity2).inbox.conversation(@conversation)[1]
  end
  
  it "should return trashed mails" do 
    @entity1.mailbox.mail.move_to_trash
    
    assert @entity1.mailbox.mail.trash
    @entity1.mailbox.mail.trash.count.should==4
    @entity1.mailbox.mail.trash[0].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[0]
    @entity1.mailbox.mail.trash[1].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[1]
    @entity1.mailbox.mail.trash[2].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[2]
    @entity1.mailbox.mail.trash[3].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[3]
    
    assert @entity2.mailbox.mail.trash
    @entity2.mailbox.mail.trash.count.should==0    
  end
  
  it "should delete trashed mails" do 
    @entity1.mailbox.mail.move_to_trash
    @entity1.mailbox.empty_trash
    
    assert @entity1.mailbox.mail.trash
    @entity1.mailbox.mail.trash.count.should==0    
    
    assert @entity2.mailbox.mail
    @entity2.mailbox.mail.count.should==4
    
    assert @entity2.mailbox.mail.trash
    @entity2.mailbox.mail.trash.count.should==0    
  end
  
end
