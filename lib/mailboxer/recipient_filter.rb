module Mailboxer
  class RecipientFilter
    attr_reader :mailable, :recipients
    def initialize(mailable, recipients)
      @mailable, @recipients = mailable, recipients
    end

    # recipients can be filtered on a conversation basis
    def call
      return recipients unless mailable.respond_to?(:conversation)

      recipients.each_with_object([]) do |recipient, array|
        array << recipient if mailable.conversation.has_subscriber?(recipient)
      end
    end
  end
end
