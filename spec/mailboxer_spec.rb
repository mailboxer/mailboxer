require 'spec_helper'

describe Mailboxer do
  it "should be valid" do
    Mailboxer.should be_a(Module)
  end

  describe "configuring notification mailer" do
    before { Mailboxer.notification_mailer.should eq nil }

    it "can override notification mailer" do
      Mailboxer.notification_mailer = "foo"
      Mailboxer.notification_mailer.should eq "foo"
    end

    after { Mailboxer.notification_mailer.should eq nil }
  end
end
