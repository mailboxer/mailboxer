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
        expect(ActionMailer::Base.deliveries).not_to be_empty
        expect(ActionMailer::Base.deliveries).to have(1).item
      end

      it "should send an email to user entity" do
        expect(sent_to?(entity1)).to be true
      end

      it "shouldn't send an email to duck entity" do
        expect(sent_to?(entity2)).to be false
      end

      it "shouldn't send an email to cylon entity" do
        expect(sent_to?(entity3)).to be false
      end
    end

    describe "when replying" do
      before do
        @receipt1 = sender.send_message([entity1, entity2, entity3], "Body", "Subject")
        @receipt2 = sender.reply_to_all(@receipt1, "Body")
      end

      it "should send emails when should_email? is true (1 out of 3)" do
        expect(ActionMailer::Base.deliveries).not_to be_empty
        expect(ActionMailer::Base.deliveries).to have(2).items
      end

      it "should send an email to user entity" do
        expect(sent_to?(entity1)).to be true
      end

      it "shouldn't send an email to duck entity" do
        expect(sent_to?(entity2)).to be false
      end

      it "shouldn't send an email to cylon entity" do
        expect(sent_to?(entity3)).to be false
      end
    end
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
