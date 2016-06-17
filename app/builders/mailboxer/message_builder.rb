class Mailboxer::MessageBuilder < Mailboxer::BaseBuilder

  protected

  def klass
    Mailboxer::Message
  end
end
