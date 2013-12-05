class Mailboxer::MessageBuilder < Mailboxer::BaseBuilder

  protected

  def klass
    Mailboxer::Message
  end

  def subject
    params[:subject] || default_subject
  end

  def default_subject
    "RE: #{params[:conversation].subject}"
  end
end
