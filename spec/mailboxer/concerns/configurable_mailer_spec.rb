require 'spec_helper'
describe Concerns::ConfigurableMailer do

  describe "Notification instance#get_mailer" do
    before { @obj = Notification.new }
    it "returns default_mailer" do
      @obj.get_mailer.should eq NotificationMailer
    end
    it "returns 'foo' from Mailerbox.notification_mailer" do
      Mailboxer.notification_mailer = 'foo'
      @obj.get_mailer.should eq 'foo'
    end
    after { Mailboxer.notification_mailer = nil }
  end

  describe "Message instance#get_mailer" do
    before { @obj = Message.new }
    it "returns default_mailer" do
      @obj.get_mailer.should eq MessageMailer
    end
    it "returns 'foo' from Mailerbox.message_mailer" do
      Mailboxer.message_mailer = 'foo'
      @obj.get_mailer.should eq 'foo'
    end
    after { Mailboxer.message_mailer = nil }
  end
end
