require 'spec_helper'

describe Mailboxer::Notification do

  before do
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:user)
    @entity3 = FactoryGirl.create(:user)
  end

  it { should validate_presence_of :body }

  it { should validate_length_of(:subject).is_at_most(Mailboxer.subject_max_length) }
  it { should validate_length_of(:body).is_at_most(Mailboxer.body_max_length) }

  it "should notify one user" do
    @entity1.send(Mailboxer.notify_method, "Subject", "Body")

    #Check getting ALL receipts
    expect(@entity1.mailbox.receipts.size).to eq 1
    receipt      = @entity1.mailbox.receipts.first
    notification = receipt.notification
    expect(notification.subject).to eq "Subject"
    expect(notification.body).to eq "Body"

    #Check getting NOTIFICATION receipts only
    expect(@entity1.mailbox.notifications.size).to eq 1
    notification = @entity1.mailbox.notifications.first
    expect(notification.subject).to eq "Subject"
    expect(notification.body).to eq "Body"
  end

  it "should be unread by default" do
    @entity1.send(Mailboxer.notify_method, "Subject", "Body")
    expect(@entity1.mailbox.receipts.size).to eq 1
    notification = @entity1.mailbox.receipts.first.notification
    expect(notification).to be_is_unread(@entity1)
  end

  it "should be able to marked as read" do
    @entity1.send(Mailboxer.notify_method, "Subject", "Body")
    expect(@entity1.mailbox.receipts.size).to eq 1
    notification = @entity1.mailbox.receipts.first.notification
    notification.mark_as_read(@entity1)
    expect(notification).to be_is_read(@entity1)
  end

  it "should be able to specify a sender for a notification" do
    @entity1.send(Mailboxer.notify_method, "Subject", "Body", nil, true, nil, true, @entity3)
    expect(@entity1.mailbox.receipts.size).to eq 1
    notification = @entity1.mailbox.receipts.first.notification
    expect(notification.sender).to eq(@entity3)
  end

  it "should notify several users" do
    recipients = [@entity1,@entity2,@entity3]
    Mailboxer::Notification.notify_all(recipients,"Subject","Body")
    #Check getting ALL receipts
    expect(@entity1.mailbox.receipts.size).to eq 1
    receipt      = @entity1.mailbox.receipts.first
    notification = receipt.notification
    expect(notification.subject).to eq "Subject"
    expect(notification.body).to eq "Body"
    expect(@entity2.mailbox.receipts.size).to eq 1
    receipt      = @entity2.mailbox.receipts.first
    notification = receipt.notification
    expect(notification.subject).to eq "Subject"
    expect(notification.body).to eq "Body"
    expect(@entity3.mailbox.receipts.size).to eq 1
    receipt      = @entity3.mailbox.receipts.first
    notification = receipt.notification
    expect(notification.subject).to eq "Subject"
    expect(notification.body).to eq "Body"

    #Check getting NOTIFICATION receipts only
    expect(@entity1.mailbox.notifications.size).to eq 1
    notification = @entity1.mailbox.notifications.first
    expect(notification.subject).to eq "Subject"
    expect(notification.body).to eq "Body"
    expect(@entity2.mailbox.notifications.size).to eq 1
    notification = @entity2.mailbox.notifications.first
    expect(notification.subject).to eq "Subject"
    expect(notification.body).to eq "Body"
    expect(@entity3.mailbox.notifications.size).to eq 1
    notification = @entity3.mailbox.notifications.first
    expect(notification.subject).to eq "Subject"
    expect(notification.body).to eq "Body"

  end

  it "should notify a single recipient" do
    Mailboxer::Notification.notify_all(@entity1,"Subject","Body")

    #Check getting ALL receipts
    expect(@entity1.mailbox.receipts.size).to eq 1
    receipt      = @entity1.mailbox.receipts.first
    notification = receipt.notification
    expect(notification.subject).to eq "Subject"
    expect(notification.body).to eq "Body"

    #Check getting NOTIFICATION receipts only
    expect(@entity1.mailbox.notifications.size).to eq 1
    notification = @entity1.mailbox.notifications.first
    expect(notification.subject).to eq "Subject"
    expect(notification.body).to eq "Body"
  end

  it "should be able to specify a sender for a notification" do
    Mailboxer::Notification.notify_all(@entity1,"Subject","Body", nil, true, nil, false, @entity3)

    #Check getting ALL receipts
    expect(@entity1.mailbox.receipts.size).to eq 1
    receipt      = @entity1.mailbox.receipts.first
    notification = receipt.notification
    expect(notification.subject).to eq "Subject"
    expect(notification.body).to eq "Body"
    expect(notification.sender).to eq @entity3

    #Check getting NOTIFICATION receipts only
    expect(@entity1.mailbox.notifications.size).to eq 1
    notification = @entity1.mailbox.notifications.first
    expect(notification.subject).to eq "Subject"
    expect(notification.body).to eq "Body"
    expect(notification.sender).to eq @entity3
  end

  describe "scopes" do
    let(:scope_user) { FactoryGirl.create(:user) }
    let!(:notification) { scope_user.send(Mailboxer.notify_method, "Body", "Subject").notification }

    describe ".unread" do
      it "finds unread notifications" do
        unread_notification = scope_user.send(Mailboxer.notify_method, "Body", "Subject").notification
        notification.mark_as_read(scope_user)
        expect(Mailboxer::Notification.unread.last).to eq unread_notification
      end
    end

    describe ".expired" do
      it "finds expired notifications" do
        notification.update_attributes(expires: 1.day.ago)
        expect(scope_user.mailbox.notifications.expired.count).to eq(1)
      end
    end

    describe ".unexpired" do
      it "finds unexpired notifications" do
        notification.update_attributes(expires: 1.day.from_now)
        expect(scope_user.mailbox.notifications.unexpired.count).to eq(1)
      end
    end
  end

  describe "#expire" do
    subject { described_class.new }

    describe "when the notification is already expired" do
      before do
        allow(subject).to receive(:expired?).and_return(true)
      end
      it 'should not update the expires attribute' do
        expect(subject).not_to receive :expires=
        expect(subject).not_to receive :save
        subject.expire
      end
    end

    describe "when the notification is not expired" do
      let(:now) { Time.now }
      let(:one_second_ago) { now - 1.second }
      before do
        allow(Time).to receive(:now).and_return(now)
        allow(subject).to receive(:expired?).and_return(false)
      end
      it 'should update the expires attribute' do
        expect(subject).to receive(:expires=).with(one_second_ago)
        subject.expire
      end
      it 'should not save the record' do
        expect(subject).not_to receive :save
        subject.expire
      end
    end

  end

  describe "#expire!" do
    subject { described_class.new }

    describe "when the notification is already expired" do
      before do
        allow(subject).to receive(:expired?).and_return(true)
      end
      it 'should not call expire' do
        expect(subject).not_to receive :expire
        expect(subject).not_to receive :save
        subject.expire!
      end
    end

    describe "when the notification is not expired" do
      let(:now) { Time.now }
      let(:one_second_ago) { now - 1.second }
      before do
        allow(Time).to receive(:now).and_return(now)
        allow(subject).to receive(:expired?).and_return(false)
      end
      it 'should call expire' do
        expect(subject).to receive(:expire)
        subject.expire!
      end
      it 'should save the record' do
        expect(subject).to receive :save
        subject.expire!
      end
    end

  end

  describe "#expired?" do
    subject { described_class.new }
    context "when the expiration date is in the past" do
      before { allow(subject).to receive(:expires).and_return(Time.now - 1.second) }
      it 'should be expired' do
        expect(subject.expired?).to be true
      end
    end

    context "when the expiration date is now" do
      before {
        time = Time.now
        allow(Time).to receive(:now).and_return(time)
        allow(subject).to receive(:expires).and_return(time)
      }

      it 'should not be expired' do
        expect(subject.expired?).to be false
      end
    end

    context "when the expiration date is in the future" do
      before { allow(subject).to receive(:expires).and_return(Time.now + 1.second) }
      it 'should not be expired' do
        expect(subject.expired?).to be false
      end
    end

    context "when the expiration date is not set" do
      before { allow(subject).to receive(:expires).and_return(nil) }
      it 'should not be expired' do
        expect(subject.expired?).to be false
      end
    end

  end

end
