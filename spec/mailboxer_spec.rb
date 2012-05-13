require 'spec_helper'

describe Mailboxer do
  it "should be valid" do
    Mailboxer.should be_a(Module)
  end
end
