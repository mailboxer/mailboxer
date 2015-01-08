require 'spec_helper'

describe "Messages And Mailboxer::Receipts", type: :integration do

  describe "two equal entities" do
    before do
      @entity1 = FactoryGirl.create(:user)
      @entity2 = FactoryGirl.create(:user)
    end

    describe "message sending" do

      before do
        @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
        @message1 = @receipt1.notification
      end

      it "should create proper message" do
        expect(@message1.sender.id).to eq @entity1.id
        expect(@message1.sender.class).to eq @entity1.class
        assert @message1.body.eql?"Body"
        assert @message1.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end
      end

      it "should have the correct recipients" do
        recipients = @message1.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
      end

    end

    describe "message replying to sender" do
      before do
        @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
        @receipt2 = @entity2.reply_to_sender(@receipt1,"Reply body")
        @message1 = @receipt1.notification
        @message2 = @receipt2.notification
      end

      it "should create proper message" do
        expect(@message2.sender.id).to eq @entity2.id
        expect(@message2.sender.class).to eq @entity2.class
        expect(@message2.body).to eq "Reply body"
        expect(@message2.subject).to eq "Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end
      end

      it "should have the correct recipients" do
        recipients = @message2.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
      end

      it "should be associated to the same conversation" do
        expect(@message1.conversation.id).to eq @message2.conversation.id
      end
    end

    describe "message replying to all" do
      before do
        @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
        @receipt2 = @entity2.reply_to_all(@receipt1,"Reply body")
        @message1 = @receipt1.notification
        @message2 = @receipt2.notification
      end

      it "should create proper message" do
        expect(@message2.sender.id).to eq @entity2.id
        expect(@message2.sender.class).to eq @entity2.class
        assert @message2.body.eql?"Reply body"
        assert @message2.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end
      end

      it "should have the correct recipients" do
        recipients = @message2.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
      end

      it "should be associated to the same conversation" do
        expect(@message1.conversation.id).to eq @message2.conversation.id
      end
    end
    describe "message replying to conversation" do
      before do
        @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
        @receipt2 = @entity2.reply_to_conversation(@receipt1.conversation,"Reply body")
        @message1 = @receipt1.notification
        @message2 = @receipt2.notification
      end

      it "should create proper message" do
        expect(@message2.sender.id).to eq @entity2.id
        expect(@message2.sender.class).to eq @entity2.class
        assert @message2.body.eql?"Reply body"
        assert @message2.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end
      end

      it "should have the correct recipients" do
        recipients = @message2.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
      end

      it "should be associated to the same conversation" do
        expect(@message1.conversation.id).to eq @message2.conversation.id
      end
    end
  end

  describe "two different entities" do
    before do
      @entity1 = FactoryGirl.create(:user)
      @entity2 = FactoryGirl.create(:duck)
    end

    describe "message sending" do

      before do
        @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
        @message1 = @receipt1.notification
      end

      it "should create proper message" do
        expect(@message1.sender.id).to eq @entity1.id
        expect(@message1.sender.class).to eq @entity1.class
        assert @message1.body.eql?"Body"
        assert @message1.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end
      end

      it "should have the correct recipients" do
        recipients = @message1.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
      end

    end

    describe "message replying to sender" do
      before do
        @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
        @receipt2 = @entity2.reply_to_sender(@receipt1,"Reply body")
        @message1 = @receipt1.notification
        @message2 = @receipt2.notification
      end

      it "should create proper message" do
        expect(@message2.sender.id).to eq @entity2.id
        expect(@message2.sender.class).to eq @entity2.class
        assert @message2.body.eql?"Reply body"
        assert @message2.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end
      end

      it "should have the correct recipients" do
        recipients = @message2.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
      end

      it "should be associated to the same conversation" do
        expect(@message1.conversation.id).to eq @message2.conversation.id
      end
    end

    describe "message replying to all" do
      before do
        @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
        @receipt2 = @entity2.reply_to_all(@receipt1,"Reply body")
        @message1 = @receipt1.notification
        @message2 = @receipt2.notification
      end

      it "should create proper message" do
        expect(@message2.sender.id).to eq @entity2.id
        expect(@message2.sender.class).to eq @entity2.class
        assert @message2.body.eql?"Reply body"
        assert @message2.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end
      end

      it "should have the correct recipients" do
        recipients = @message2.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
      end

      it "should be associated to the same conversation" do
        expect(@message1.conversation.id).to eq @message2.conversation.id
      end
    end
    describe "message replying to conversation (TODO)" do
      before do
        #TODO
      end

      it "should create proper message" do
        #TODO
      end

      it "should create proper mails" do
        #TODO
      end

      it "should have the correct recipients" do
        #TODO
      end

      it "should be associated to the same conversation" do
        #TODO
      end
    end
  end

  describe "three equal entities" do
    before do
      @entity1 = FactoryGirl.create(:user)
      @entity2 = FactoryGirl.create(:user)
      @entity3 = FactoryGirl.create(:user)
      @recipients = Array.new
      @recipients << @entity2
      @recipients << @entity3
    end

    describe "message sending" do

      before do
        @receipt1 = @entity1.send_message(@recipients,"Body","Subject")
        @message1 = @receipt1.notification
      end

      it "should create proper message" do
        expect(@message1.sender.id).to eq @entity1.id
        expect(@message1.sender.class).to eq @entity1.class
        assert @message1.body.eql?"Body"
        assert @message1.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mails
        @recipients.each do |receiver|
          mail = Mailboxer::Receipt.recipient(receiver).notification(@message1).first
          assert mail
          if mail
            expect(mail.is_read).to be false
            expect(mail.trashed).to be false
            expect(mail.mailbox_type).to eq "inbox"
          end
        end
      end

      it "should have the correct recipients" do
        recipients = @message1.recipients
        expect(recipients.count).to eq 3
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
        expect(recipients.count(@entity3)).to eq 1
      end

    end

    describe "message replying to sender" do
      before do
        @receipt1 = @entity1.send_message(@recipients,"Body","Subject")
        @receipt2 = @entity2.reply_to_sender(@receipt1,"Reply body")
        @message1 = @receipt1.notification
        @message2 = @receipt2.notification
      end

      it "should create proper message" do
        expect(@message2.sender.id).to eq @entity2.id
        expect(@message2.sender.class).to eq @entity2.class
        assert @message2.body.eql?"Reply body"
        assert @message2.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end

        #No Receiver, No Mail
        mail = Mailboxer::Receipt.recipient(@entity3).notification(@message2).first
        assert mail.nil?

      end

      it "should have the correct recipients" do
        recipients = @message2.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
        expect(recipients.count(@entity3)).to eq 0
      end

      it "should be associated to the same conversation" do
        expect(@message1.conversation.id).to eq @message2.conversation.id
      end
    end

    describe "message replying to all" do
      before do
        @receipt1 = @entity1.send_message(@recipients,"Body","Subject")
        @receipt2 = @entity2.reply_to_all(@receipt1,"Reply body")
        @message1 = @receipt1.notification
        @message2 = @receipt2.notification
        @recipients2 = Array.new
        @recipients2 << @entity1
        @recipients2 << @entity3

      end

      it "should create proper message" do
        expect(@message2.sender.id).to eq @entity2.id
        expect(@message2.sender.class).to eq @entity2.class
        assert @message2.body.eql?"Reply body"
        assert @message2.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mails
        @recipients2.each do |receiver|
          mail = Mailboxer::Receipt.recipient(receiver).notification(@message2).first
          assert mail
          if mail
            expect(mail.is_read).to be false
            expect(mail.trashed).to be false
            expect(mail.mailbox_type).to eq "inbox"
          end
        end
      end

      it "should have the correct recipients" do
        recipients = @message2.recipients
        expect(recipients.count).to eq 3
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
        expect(recipients.count(@entity3)).to eq 1
      end

      it "should be associated to the same conversation" do
        expect(@message1.conversation.id).to eq @message2.conversation.id
      end
    end
    describe "message replying to conversation (TODO)" do
      before do
        #TODO
      end

      it "should create proper message" do
        #TODO
      end

      it "should create proper mails" do
        #TODO
      end

      it "should have the correct recipients" do
        #TODO
      end

      it "should be associated to the same conversation" do
        #TODO
      end
    end
  end

  describe "three different entities" do
    before do
      @entity1 = FactoryGirl.create(:user)
      @entity2 = FactoryGirl.create(:duck)
      @entity3 = FactoryGirl.create(:cylon)
      @recipients = Array.new
      @recipients << @entity2
      @recipients << @entity3
    end

    describe "message sending" do

      before do
        @receipt1 = @entity1.send_message(@recipients,"Body","Subject")
        @message1 = @receipt1.notification
      end

      it "should create proper message" do
        expect(@message1.sender.id).to eq @entity1.id
        expect(@message1.sender.class).to eq @entity1.class
        assert @message1.body.eql?"Body"
        assert @message1.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mails
        @recipients.each do |receiver|
          mail = Mailboxer::Receipt.recipient(receiver).notification(@message1).first
          assert mail
          if mail
            expect(mail.is_read).to be false
            expect(mail.trashed).to be false
            expect(mail.mailbox_type).to eq "inbox"
          end
        end
      end

      it "should have the correct recipients" do
        recipients = @message1.recipients
        expect(recipients.count).to eq 3
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
        expect(recipients.count(@entity3)).to eq 1
      end

    end

    describe "message replying to sender" do
      before do
        @receipt1 = @entity1.send_message(@recipients,"Body","Subject")
        @receipt2 = @entity2.reply_to_sender(@receipt1,"Reply body")
        @message1 = @receipt1.notification
        @message2 = @receipt2.notification
      end

      it "should create proper message" do
        expect(@message2.sender.id).to eq @entity2.id
        expect(@message2.sender.class).to eq @entity2.class
        assert @message2.body.eql?"Reply body"
        assert @message2.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end

        #No Receiver, No Mail
        mail = Mailboxer::Receipt.recipient(@entity3).notification(@message2).first
        assert mail.nil?

      end

      it "should have the correct recipients" do
        recipients = @message2.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
        expect(recipients.count(@entity3)).to eq 0
      end

      it "should be associated to the same conversation" do
        expect(@message1.conversation.id).to eq @message2.conversation.id
      end
    end

    describe "message replying to all" do
      before do
        @receipt1 = @entity1.send_message(@recipients,"Body","Subject")
        @receipt2 = @entity2.reply_to_all(@receipt1,"Reply body")
        @message1 = @receipt1.notification
        @message2 = @receipt2.notification
        @recipients2 = Array.new
        @recipients2 << @entity1
        @recipients2 << @entity3

      end

      it "should create proper message" do
        expect(@message2.sender.id).to eq @entity2.id
        expect(@message2.sender.class).to eq @entity2.class
        assert @message2.body.eql?"Reply body"
        assert @message2.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mails
        @recipients2.each do |receiver|
          mail = Mailboxer::Receipt.recipient(receiver).notification(@message2).first
          assert mail
          if mail
            expect(mail.is_read).to be false
            expect(mail.trashed).to be false
            expect(mail.mailbox_type).to eq "inbox"
          end
        end
      end

      it "should have the correct recipients" do
        recipients = @message2.recipients
        expect(recipients.count).to eq 3
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
        expect(recipients.count(@entity3)).to eq 1
      end

      it "should be associated to the same conversation" do
        expect(@message1.conversation.id).to eq @message2.conversation.id
      end
    end

    describe "message replying to conversation (TODO)" do
      before do
        #TODO
      end

      it "should create proper message" do
        #TODO
      end

      it "should create proper mails" do
        #TODO
      end

      it "should have the correct recipients" do
        #TODO
      end

      it "should be associated to the same conversation" do
        #TODO
      end
    end
  end

  describe "two STI entities" do
    before do
      @entity1 = FactoryGirl.create(:user)
      @entity2 = FactoryGirl.create(:user)
    end

    describe "message sending" do

      before do
        @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
        @message1 = @receipt1.notification
      end

      it "should create proper message" do
        expect(@message1.sender.id).to eq @entity1.id
        expect(@message1.sender.class).to eq @entity1.class
        assert @message1.body.eql?"Body"
        assert @message1.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message1).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end
      end

      it "should have the correct recipients" do
        recipients = @message1.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
      end

    end

    describe "message replying to sender" do
      before do
        @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
        @receipt2 = @entity2.reply_to_sender(@receipt1,"Reply body")
        @message1 = @receipt1.notification
        @message2 = @receipt2.notification
      end

      it "should create proper message" do
        expect(@message2.sender.id).to eq @entity2.id
        expect(@message2.sender.class).to eq @entity2.class
        assert @message2.body.eql?"Reply body"
        assert @message2.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end
      end

      it "should have the correct recipients" do
        recipients = @message2.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
      end

      it "should be associated to the same conversation" do
        expect(@message1.conversation.id).to eq @message2.conversation.id
      end
    end

    describe "message replying to all" do
      before do
        @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
        @receipt2 = @entity2.reply_to_all(@receipt1,"Reply body")
        @message1 = @receipt1.notification
        @message2 = @receipt2.notification
      end

      it "should create proper message" do
        expect(@message2.sender.id).to eq @entity2.id
        expect(@message2.sender.class).to eq @entity2.class
        assert @message2.body.eql?"Reply body"
        assert @message2.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end
      end

      it "should have the correct recipients" do
        recipients = @message2.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
      end

      it "should be associated to the same conversation" do
        expect(@message1.conversation.id).to eq @message2.conversation.id
      end
    end
    describe "message replying to conversation" do
      before do
        @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
        @receipt2 = @entity2.reply_to_conversation(@receipt1.conversation,"Reply body")
        @message1 = @receipt1.notification
        @message2 = @receipt2.notification
      end

      it "should create proper message" do
        expect(@message2.sender.id).to eq @entity2.id
        expect(@message2.sender.class).to eq @entity2.class
        assert @message2.body.eql?"Reply body"
        assert @message2.subject.eql?"Subject"
      end

      it "should create proper mails" do
        #Sender Mail
        mail = Mailboxer::Receipt.recipient(@entity2).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be true
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "sentbox"
        end
        #Receiver Mail
        mail = Mailboxer::Receipt.recipient(@entity1).notification(@message2).first
        assert mail
        if mail
          expect(mail.is_read).to be false
          expect(mail.trashed).to be false
          expect(mail.mailbox_type).to eq "inbox"
        end
      end

      it "should have the correct recipients" do
        recipients = @message2.recipients
        expect(recipients.count).to eq 2
        expect(recipients.count(@entity1)).to eq 1
        expect(recipients.count(@entity2)).to eq 1
      end

      it "should be associated to the same conversation" do
        expect(@message1.conversation.id).to eq @message2.conversation.id
      end
    end
  end
end
