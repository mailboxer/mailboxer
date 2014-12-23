require 'spec_helper'

describe Mailboxer::NotificationMailer do
  before do
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:duck)
    @entity3 = FactoryGirl.create(:cylon)
    @receipt1 = Mailboxer::Notification.notify_all([@entity1,@entity2,@entity3],"Subject", "Body Body Body Body Body Body Body Body Body Body Body Body")
  end

  it "should send emails when should_email? is true (2 out of 3)" do
    expect(ActionMailer::Base.deliveries.size).to eq 2
  end

  it "should send an email to user entity" do
    temp = false
    ActionMailer::Base.deliveries.each do |email|
      if email.to.first.to_s.eql? @entity1.email
      temp = true
      end
    end
    expect(temp).to be true
  end

  it "should send an email to duck entity" do
    temp = false
    ActionMailer::Base.deliveries.each do |email|
      if email.to.first.to_s.eql? @entity2.email
      temp = true
      end
    end
    expect(temp).to be true
  end

  it "shouldn't send an email to cylon entity" do
    temp = false
    ActionMailer::Base.deliveries.each do |email|
      if email.to.first.to_s.eql? @entity3.email
      temp = true
      end
    end
    expect(temp).to be false
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
