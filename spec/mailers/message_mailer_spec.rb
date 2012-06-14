require 'spec_helper'

describe MessageMailer do
  describe "when sending new message" do
    before do
      @sender = FactoryGirl.create(:user)
      @entity1 = FactoryGirl.create(:user)
      @entity2 = FactoryGirl.create(:duck)
      @entity3 = FactoryGirl.create(:cylon)
      @receipt1 = @sender.send_message([@entity1,@entity2,@entity3], "Body Body Body Body Body Body Body Body Body Body Body Body","Subject")
    end

    it "should send emails when should_email? is true (1 out of 3)" do
      ActionMailer::Base.deliveries.empty?.should==false
      ActionMailer::Base.deliveries.size.should==1
    end

    it "should send an email to user entity" do
      temp = false
      ActionMailer::Base.deliveries.each do |email|
        if email.to.first.to_s.eql? @entity1.email
        temp = true
        end
      end
      temp.should==true
    end

    it "shouldn't send an email to duck entity" do
      temp = false
      ActionMailer::Base.deliveries.each do |email|
        if email.to.first.to_s.eql? @entity2.email
        temp = true
        end
      end
      temp.should==false
    end

    it "shouldn't send an email to cylon entity" do
      temp = false
      ActionMailer::Base.deliveries.each do |email|
        if email.to.first.to_s.eql? @entity3.email
        temp = true
        end
      end
      temp.should==false
    end
  end

  describe "when replying" do
    before do
      @sender = FactoryGirl.create(:user)
      @entity1 = FactoryGirl.create(:user)
      @entity2 = FactoryGirl.create(:duck)
      @entity3 = FactoryGirl.create(:cylon)
      @receipt1 = @sender.send_message([@entity1,@entity2,@entity3], "Body","Subject")
      @receipt2 = @sender.reply_to_all(@receipt1, "Body")
    end
    
    it "should send emails when should_email? is true (1 out of 3)" do
      ActionMailer::Base.deliveries.empty?.should==false
      ActionMailer::Base.deliveries.size.should==2
    end

    it "should send an email to user entity" do
      temp = false
      ActionMailer::Base.deliveries.each do |email|
        if email.to.first.to_s.eql? @entity1.email
        temp = true
        end
      end
      temp.should==true
    end

    it "shouldn't send an email to duck entity" do
      temp = false
      ActionMailer::Base.deliveries.each do |email|
        if email.to.first.to_s.eql? @entity2.email
        temp = true
        end
      end
      temp.should==false
    end

    it "shouldn't send an email to cylon entity" do
      temp = false
      ActionMailer::Base.deliveries.each do |email|
        if email.to.first.to_s.eql? @entity3.email
        temp = true
        end
      end
      temp.should==false
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
