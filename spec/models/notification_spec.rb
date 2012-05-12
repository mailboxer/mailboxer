require 'spec_helper'

describe Message do
  
  before do
    @entity1 = Factory(:user)
    @entity2 = Factory(:user)
    @entity3 = Factory(:user)
  end  
  
  it "should notify one user" do
    @entity1.notify("Subject","Body")
    
    #Check getting ALL receipts
    @entity1.mailbox.receipts.size.should==1
    receipt = @entity1.mailbox.receipts.first
    notification = receipt.notification
    notification.subject.should=="Subject"
    notification.body.should=="Body"
    
    #Check getting NOTIFICATION receipts only
    @entity1.mailbox.notifications.size.should==1
    notification = @entity1.mailbox.notifications.first
    notification.subject.should=="Subject"
    notification.body.should=="Body"       
  end
  
  it "should notify several users" do
    Notification.notify_all([@entity1,@entity2,@entity3],"Subject","Body")
    
    #Check getting ALL receipts
    @entity1.mailbox.receipts.size.should==1
    receipt = @entity1.mailbox.receipts.first
    notification = receipt.notification
    notification.subject.should=="Subject"
    notification.body.should=="Body"
    @entity2.mailbox.receipts.size.should==1
    receipt = @entity2.mailbox.receipts.first
    notification = receipt.notification
    notification.subject.should=="Subject"
    notification.body.should=="Body"
    @entity3.mailbox.receipts.size.should==1
    receipt = @entity3.mailbox.receipts.first
    notification = receipt.notification
    notification.subject.should=="Subject"
    notification.body.should=="Body"
    
    #Check getting NOTIFICATION receipts only
    @entity1.mailbox.notifications.size.should==1
    notification = @entity1.mailbox.notifications.first
    notification.subject.should=="Subject"
    notification.body.should=="Body"
    @entity2.mailbox.notifications.size.should==1
    notification = @entity2.mailbox.notifications.first
    notification.subject.should=="Subject"
    notification.body.should=="Body"
    @entity3.mailbox.notifications.size.should==1
    notification = @entity3.mailbox.notifications.first
    notification.subject.should=="Subject"
    notification.body.should=="Body"
          
  end

  describe "#get_mailer obtains mailer from config" do
    before { Mailboxer.notification_mailer.should be_nil }

    it "defaults to NotificationMailer" do
      subject.get_mailer.should eq NotificationMailer
    end
    it "can be overriden on Mailboxer" do
      Mailboxer.notification_mailer = 'foo'
      subject.get_mailer.should eq 'foo'
    end

    after { Mailboxer.notification_mailer = nil }
  end
end
