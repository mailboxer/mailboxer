require 'spec_helper'

describe Mailboxer::MessageMailer do
  shared_examples 'message_mailer' do
    let(:sender) { FactoryGirl.create(:user) }
    let(:entity1) { FactoryGirl.create(:user) }
    let(:entity2) { FactoryGirl.create(:duck) }
    let(:entity3) { FactoryGirl.create(:cylon) }

    def sent_to?(entity)
      ActionMailer::Base.deliveries.any? do |email|
        email.to.first.to_s == entity.email
      end
    end

    describe "when sending new message" do
      before do
        @receipt1 = sender.send_message([entity1, entity2, entity3], "Body", "Subject")
      end

      it "should send emails when should_email? is true (1 out of 3)" do
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.should have(1).item
      end

      it "should send an email to user entity" do
        sent_to?(entity1).should be_true
      end

      it "shouldn't send an email to duck entity" do
        sent_to?(entity2).should be_false
      end

      it "shouldn't send an email to cylon entity" do
        sent_to?(entity3).should be_false
      end
    end

    describe "when replying" do
      before do
        @receipt1 = sender.send_message([entity1, entity2, entity3], "Body", "Subject")
        @receipt2 = sender.reply_to_all(@receipt1, "Body")
      end

      it "should send emails when should_email? is true (1 out of 3)" do
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.should have(2).items
      end

      it "should send an email to user entity" do
        sent_to?(entity1).should be_true
      end

      it "shouldn't send an email to duck entity" do
        sent_to?(entity2).should be_false
      end

      it "shouldn't send an email to cylon entity" do
        sent_to?(entity3).should be_false
      end
    end
  end

  context "when mailer_wants_array is false" do
    it_behaves_like 'message_mailer'
  end

  context "mailer_wants_array is true" do
    class ArrayMailer < Mailboxer::MessageMailer
      default template_path: 'mailboxer/message_mailer'

      def new_message_email(message, receivers)
        receivers.each { |receiver| super(message, receiver) if receiver.mailboxer_email(message).present? }
      end

      def reply_message_email(message, receivers)
        receivers.each { |receiver| super(message, receiver) if receiver.mailboxer_email(message).present? }
      end
    end

    before :all do
      Mailboxer.mailer_wants_array = true
      Mailboxer.message_mailer = ArrayMailer
    end

    after :all do
      Mailboxer.mailer_wants_array = false
      Mailboxer.message_mailer = Mailboxer::MessageMailer
    end

    it_behaves_like 'message_mailer'
  end
end

def print_emails
  ActionMailer::Base.deliveries.each do |email|
    puts "----------------------------------------------------"
    puts email.to
    puts "---"
    puts email.from
    puts "---"
    puts email.subject
    puts "---"
    puts email.body
    puts "---"
    puts email.encoded
    puts "----------------------------------------------------"
  end
end
