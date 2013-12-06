module Mailboxer
  class Conversation
    class OptOut < ActiveRecord::Base
      self.table_name = :mailboxer_conversation_opt_outs

      belongs_to :conversation, :class_name => "Mailboxer::Conversation"
    end
  end
end
