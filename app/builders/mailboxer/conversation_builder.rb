class Mailboxer::ConversationBuilder < Mailboxer::BaseBuilder

  private

  def fields
    %w(subject created_at updated_at)
  end


  def klass
    Mailboxer::Conversation
  end
end
