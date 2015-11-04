require 'spec_helper'

describe Mailboxer::RecipientFilter do
  subject(:instance) { described_class.new(mailable, recipients) }
  let(:recipient1) { double 'recipient1', id: 1, mailboxer_email: '' }
  let(:recipient2) { double 'recipient2', id: 2, mailboxer_email: 'foo@bar.com'}
  let(:recipients) { [ recipient1, recipient2 ] }

  describe "call" do
    context "responds to conversation" do
      let(:conversation) { double 'conversation' }
      let(:mailable)     { double 'mailable', :conversation => conversation }
      before(:each) do
        expect(conversation).to receive(:has_subscriber?).with(recipient1).and_return false
        expect(conversation).to receive(:has_subscriber?).with(recipient2).and_return true
      end

      its(:call){ should eq [recipient2] }
    end

    context 'doesnt respond to conversation' do
      let(:mailable) { double 'mailable' }
      its(:call){ should eq recipients }
    end
  end
end
