require 'spec_helper'

describe Mailboxer::Conversation do

  let!(:entity1)  { FactoryGirl.create(:user) }
  let!(:entity2)  { FactoryGirl.create(:user) }
  let!(:receipt1) { entity1.send_message(entity2,"Body","Subject") }
  let!(:receipt2) { entity2.reply_to_all(receipt1,"Reply body 1") }
  let!(:receipt3) { entity1.reply_to_all(receipt2,"Reply body 2") }
  let!(:receipt4) { entity2.reply_to_all(receipt3,"Reply body 3") }
  let!(:message1) { receipt1.notification }
  let!(:message4) { receipt4.notification }
  let!(:conversation) { message1.conversation }

  it { should validate_presence_of :subject }
  it { should ensure_length_of(:subject).is_at_most(Mailboxer.subject_max_length) }

  it "should have proper original message" do
    conversation.original_message.should == message1
  end

  it "should have proper originator (first sender)" do
    conversation.originator.should == entity1
  end

  it "should have proper last message" do
    conversation.last_message.should == message4
  end

  it "should have proper last sender" do
    conversation.last_sender.should == entity2
  end

  it "should have all conversation users" do
    conversation.recipients.count.should == 2
    conversation.recipients.count.should == 2
    conversation.recipients.count(entity1).should == 1
    conversation.recipients.count(entity2).should == 1
  end

  it "should be able to be marked as deleted" do
    conversation.move_to_trash(entity1)
    conversation.mark_as_deleted(entity1)
    conversation.should be_is_deleted(entity1)
  end

  it "should be removed from the database once deleted by all participants" do
    conversation.mark_as_deleted(entity1)
    conversation.mark_as_deleted(entity2)
    Mailboxer::Conversation.exists?(conversation.id).should be_false
  end

  it "should be able to be marked as read" do
    conversation.mark_as_read(entity1)
    conversation.should be_is_read(entity1)
  end

  it "should be able to be marked as unread" do
    conversation.mark_as_read(entity1)
    conversation.mark_as_unread(entity1)
    conversation.should be_is_unread(entity1)
  end

  it "should be able to add a new participant" do
    new_user = FactoryGirl.create(:user)
    conversation.add_participant(new_user)
    conversation.participants.count.should == 3
    conversation.participants.should include(new_user, entity1, entity2)
    conversation.receipts_for(new_user).count.should == conversation.receipts_for(entity1).count
  end

  it "should deliver messages to new participants" do
    new_user = FactoryGirl.create(:user)
    conversation.add_participant(new_user)
    expect{
      receipt5 = entity1.reply_to_all(receipt4,"Reply body 4")
    }.to change{ conversation.receipts_for(new_user).count }.by 1
  end

  describe "scopes" do
    let(:participant) { FactoryGirl.create(:user) }
    let!(:inbox_conversation) { entity1.send_message(participant, "Body", "Subject").notification.conversation }
    let!(:sentbox_conversation) { participant.send_message(entity1, "Body", "Subject").notification.conversation }


    describe ".participant" do
      it "finds conversations with receipts for participant" do
        Mailboxer::Conversation.participant(participant).should == [sentbox_conversation, inbox_conversation]
      end
    end

    describe ".inbox" do
      it "finds inbox conversations with receipts for participant" do
        Mailboxer::Conversation.inbox(participant).should == [inbox_conversation]
      end
    end

    describe ".sentbox" do
      it "finds sentbox conversations with receipts for participant" do
        Mailboxer::Conversation.sentbox(participant).should == [sentbox_conversation]
      end
    end

    describe ".trash" do
      it "finds trash conversations with receipts for participant" do
        trashed_conversation = entity1.send_message(participant, "Body", "Subject").notification.conversation
        trashed_conversation.move_to_trash(participant)

        Mailboxer::Conversation.trash(participant).should == [trashed_conversation]
      end
    end

    describe ".unread" do
      it "finds unread conversations with receipts for participant" do
        [sentbox_conversation, inbox_conversation].each {|c| c.mark_as_read(participant) }
        unread_conversation = entity1.send_message(participant, "Body", "Subject").notification.conversation

        Mailboxer::Conversation.unread(participant).should == [unread_conversation]
      end
    end
  end

  describe "#is_completely_trashed?" do
    it "returns true if all receipts in conversation are trashed for participant" do
      conversation.move_to_trash(entity1)
      conversation.is_completely_trashed?(entity1).should be_true
    end
  end

  describe "#is_deleted?" do
    it "returns false if a recipient has not deleted the conversation" do
      conversation.is_deleted?(entity1).should be_false
    end

    it "returns true if a recipient has deleted the conversation" do
      conversation.mark_as_deleted(entity1)
      conversation.is_deleted?(entity1).should be_true
    end
  end

  describe "#is_orphaned?" do
    it "returns true if both participants have deleted the conversation" do
      conversation.mark_as_deleted(entity1)
      conversation.mark_as_deleted(entity2)
      conversation.is_orphaned?.should be_true
    end

    it "returns false if one has not deleted the conversation" do
      conversation.mark_as_deleted(entity1)
      conversation.is_orphaned?.should be_false
    end
  end


  describe "#opt_out" do
    context 'participant still opt in' do
      let(:opt_out) { conversation.opt_outs.first }

      it "creates an opt_out object" do
        expect{
          conversation.opt_out(entity1)
        }.to change{ conversation.opt_outs.count}.by 1
      end

      it "creates opt out object linked to the proper conversation and participant" do
        conversation.opt_out(entity1)
        expect(opt_out.conversation).to eq conversation
        expect(opt_out.unsubscriber).to eq entity1
      end
    end

    context 'participant already opted out' do
      before do
        conversation.opt_out(entity1)
      end
      it 'does nothing' do
        expect{
          conversation.opt_out(entity1)
        }.to_not change{ conversation.opt_outs.count}
      end
    end
  end

  describe "#opt_out" do
    context 'participant already opt in' do
      it "does nothing" do
        expect{
          conversation.opt_in(entity1)
        }.to_not change{ conversation.opt_outs.count }
      end
    end

    context 'participant opted out' do
      before do
        conversation.opt_out(entity1)
      end
      it 'destroys the opt out object' do
        expect{
          conversation.opt_in(entity1)
        }.to change{ conversation.opt_outs.count}.by -1
      end
    end
  end

  describe "#subscriber?" do
    let(:action) { conversation.has_subscriber?(entity1) }

    context 'participant opted in' do
      it "returns true" do
        expect(action).to be_true
      end
    end

    context 'participant opted out' do
      before do
        conversation.opt_out(entity1)
      end
      it 'returns false' do
        expect(action).to be_false
      end
    end
  end

end
