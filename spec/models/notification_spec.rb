require 'spec_helper'

describe Message do

  before do
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:user)
    @entity3 = FactoryGirl.create(:user)
  end

  it "should notify one user" do
    @entity1.notify("Subject", "Body")

    #Check getting ALL receipts
    @entity1.mailbox.receipts.size.should==1
    receipt      = @entity1.mailbox.receipts.first
    notification = receipt.notification
    notification.subject.should=="Subject"
    notification.body.should=="Body"

    #Check getting NOTIFICATION receipts only
    @entity1.mailbox.notifications.size.should==1
    notification = @entity1.mailbox.notifications.first
    notification.subject.should=="Subject"
    notification.body.should=="Body"
  end

  it "should be unread by default" do
    @entity1.notify("Subject", "Body")
    @entity1.mailbox.receipts.size.should==1
    notification = @entity1.mailbox.receipts.first.notification
    notification.should be_is_unread(@entity1)
  end

  it "should be able to marked as read" do
    @entity1.notify("Subject", "Body")
    @entity1.mailbox.receipts.size.should==1
    notification = @entity1.mailbox.receipts.first.notification
    notification.mark_as_read(@entity1)
    notification.should be_is_read(@entity1)
  end

  it "should notify several users" do
    recipients = Set.new [@entity1, @entity2, @entity3]
    Notification.notify_all(recipients, "Subject", "Body")

    #Check getting ALL receipts
    @entity1.mailbox.receipts.size.should==1
    receipt      = @entity1.mailbox.receipts.first
    notification = receipt.notification
    notification.subject.should=="Subject"
    notification.body.should=="Body"
    @entity2.mailbox.receipts.size.should==1
    receipt      = @entity2.mailbox.receipts.first
    notification = receipt.notification
    notification.subject.should=="Subject"
    notification.body.should=="Body"
    @entity3.mailbox.receipts.size.should==1
    receipt      = @entity3.mailbox.receipts.first
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

  it "should notify a single recipient" do
    Notification.notify_all(@entity1, "Subject", "Body")

    #Check getting ALL receipts
    @entity1.mailbox.receipts.size.should==1
    receipt      = @entity1.mailbox.receipts.first
    notification = receipt.notification
    notification.subject.should=="Subject"
    notification.body.should=="Body"

    #Check getting NOTIFICATION receipts only
    @entity1.mailbox.notifications.size.should==1
    notification = @entity1.mailbox.notifications.first
    notification.subject.should=="Subject"
    notification.body.should=="Body"
  end
  
  describe "#expire" do
    subject { Notification.new }
    
    describe "when the notification is already expired" do
      before do
        subject.stub(:expired? => true)
      end
      it 'should not update the expires attribute' do
        subject.should_not_receive :expires=
        subject.should_not_receive :save
        subject.expire
      end
    end

    describe "when the notification is not expired" do
      let(:now) { Time.now }
      let(:one_second_ago) { now - 1.second }
      before do
        Time.stub(:now => now)
        subject.stub(:expired? => false)
      end
      it 'should update the expires attribute' do
        subject.should_receive(:expires=).with(one_second_ago)
        subject.expire
      end
      it 'should not save the record' do
        subject.should_not_receive :save
        subject.expire
      end
    end
    
  end
  
  describe "#expire!" do
    subject { Notification.new }

    describe "when the notification is already expired" do
      before do
        subject.stub(:expired? => true)
      end
      it 'should not call expire' do
        subject.should_not_receive :expire
        subject.should_not_receive :save
        subject.expire!
      end
    end

    describe "when the notification is not expired" do
      let(:now) { Time.now }
      let(:one_second_ago) { now - 1.second }
      before do
        Time.stub(:now => now)
        subject.stub(:expired? => false)
      end
      it 'should call expire' do
        subject.should_receive(:expire)
        subject.expire!
      end
      it 'should save the record' do
        subject.should_receive :save
        subject.expire!
      end
    end
    
  end

  describe "#expired?" do
    subject { Notification.new }
    context "when the expiration date is in the past" do
      before { subject.stub(:expires => Time.now - 1.second) }
      it 'should be expired' do
        subject.expired?.should be_true
      end
    end
    
    context "when the expiration date is now" do
      before {
        time = Time.now
        Time.stub(:now => time)
        subject.stub(:expires => time)
      }
      
      it 'should not be expired' do
        subject.expired?.should be_false
      end
    end
    
    context "when the expiration date is in the future" do
      before { subject.stub(:expires => Time.now + 1.second) }
      it 'should not be expired' do
        subject.expired?.should be_false
      end
    end
    
    context "when the expiration date is not set" do
      before {subject.stub(:expires => nil)}
      it 'should not be expired' do
        subject.expired?.should be_false
      end
    end
    
  end

end
