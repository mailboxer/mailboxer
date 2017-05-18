require 'spec_helper'

describe Mailboxer::MailDispatcher do

  subject(:instance) { described_class.new(mailable, receipts) }

  let(:mailable)   { Mailboxer::Notification.new }
  let(:recipient1) { double 'recipient1', id: 1, mailboxer_email: '' }
  let(:recipient2) { double 'recipient2', id: 2, mailboxer_email: 'foo@bar.com'}
  let(:receipt1) { double 'receipt1', id: 1, receiver: recipient1 }
  let(:receipt2) { double 'receipt2', id: 2, receiver: recipient2  }

  let(:receipts) { [ receipt1, receipt2 ] }

  describe "call" do
    context "no emails" do
      before { Mailboxer.uses_emails = false }
      after  { Mailboxer.uses_emails = true }
      its(:call) { should be false }
    end

    context "mailer doesn't want array" do
      it 'sends collection' do
        expect(subject).not_to receive(:send_email).with(receipt1) #email is blank
        expect(subject).to receive(:send_email).with(receipt2)
        subject.call
      end
    end
  end

  describe "send_email" do

    let(:mailer) { double 'mailer' }

    before(:each) do
      allow(subject).to receive(:mailer).and_return mailer
    end

    context "with custom_deliver_proc" do
      let(:my_proc) { double 'proc' }

      before { Mailboxer.custom_deliver_proc = my_proc }
      after  { Mailboxer.custom_deliver_proc = nil     }
      it "triggers proc" do
        expect(my_proc).to receive(:call).with(mailer, mailable, recipient1)
        subject.send :send_email, receipt1
      end
    end

    context "without custom_deliver_proc" do
      let(:email) { double :email, message_id: '123@local.com' }

      it "triggers standard deliver chain" do
        expect(mailer).to receive(:send_email).with(mailable, recipient1).and_return email
        expect(receipt1).to receive(:assign_attributes).with({:delivery_method=>:email, :message_id=>"123@local.com"}).and_return email
        expect(email).to receive :deliver

        subject.send :send_email, receipt1
      end
    end
  end

  describe "mailer" do
    let(:receipts) { [] }

    context "mailable is a Notification" do
      let(:mailable) { Mailboxer::Notification.new }

      its(:mailer) { should be Mailboxer::NotificationMailer }

      context "with custom mailer" do
        before { Mailboxer.notification_mailer = 'foo' }
        after  { Mailboxer.notification_mailer = nil   }

        its(:mailer) { should eq 'foo' }
      end
    end

    context "mailable is a Message" do
      let(:mailable) { Mailboxer::Message.new }
      its(:mailer) { should be Mailboxer::MessageMailer }

      context 'mailer class is selected using global Mailboxer method' do
        before { Mailboxer.message_mailer = 'foo' }
        after  { Mailboxer.message_mailer = nil   }

        its(:mailer) { should eq 'foo' }
      end

      context 'mailer class is selected using Mailable#mailer_class' do
        let(:mailable) { double(mailer_class: :foo) }
        its(:mailer) { should eq :foo }
      end

      context 'mailer class is selected by searching for the constant' do
        before { stub_const 'StringMailer', 1 }
        let(:mailable) { String.new('I am a string') }
        its(:mailer) { should eq Object.const_get('StringMailer') }
      end
    end
  end
end
