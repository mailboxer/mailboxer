class Mailboxer::MessageBuilder < Mailboxer::BaseBuilder

  private

  def fields
    %w( sender conversation recipients body subject
        created_at updated_at attachment )
  end

  def klass
    Mailboxer::Message
  end

  def subject
    params[:subject] || default_subject
  end

  def default_subject
    "RE: #{conversation.subject}"
  end
end
