class Mailboxer::MessageBuilder < Mailboxer::BaseBuilder

  private

  def fields
    %w( sender conversation recipients body subject
        created_at updated_at attachment )
  end

  def klass
    Mailboxer::Message
  end

  def sender
    params.fetch(:sender)
  end

  def conversation
    params.fetch(:conversation)
  end

  def subject
    params[:subject] || default_subject
  end

  def default_subject
    "RE: #{conversation.subject}"
  end

  def attachment
    params.fetch(:attachment, nil)
  end
end
