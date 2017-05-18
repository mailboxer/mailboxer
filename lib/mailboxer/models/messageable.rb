module Mailboxer
  module Models
    module Messageable
      extend ActiveSupport::Concern

      module ActiveRecordExtension
        #Converts the model into messageable allowing it to interchange messages and
        #receive notifications
        def acts_as_messageable
          include Messageable
        end
      end


      included do
        has_many :messages, :class_name => "Mailboxer::Message", :as => :sender
        has_many :receipts, -> { order(:created_at => :desc, :id => :desc) }, :class_name => "Mailboxer::Receipt", dependent: :destroy, as: :receiver
      end

      unless defined?(Mailboxer.name_method)
        # Returning any kind of identification you want for the model
        define_method Mailboxer.name_method do
          begin
            super
          rescue NameError
            return "You should add method :#{Mailboxer.name_method} in your Messageable model"
          end
        end
      end

      unless defined?(Mailboxer.email_method)
        #Returning the email address of the model if an email should be sent for this object (Message or Notification).
        #If no mail has to be sent, return nil.
        define_method Mailboxer.email_method do |object|
          begin
            super
          rescue NameError
            return "You should add method :#{Mailboxer.email_method} in your Messageable model"
          end
        end
      end

      #Sends a notification to the messageable
      define_method Mailboxer.notify_method do |subject, body, obj=nil, sanitize_text=true, notification_code=nil, send_mail=true, sender=nil|
        Mailboxer::Notification.notify_all([self],subject,body,obj,sanitize_text,notification_code,send_mail,sender)
      end

      #Gets the mailbox of the messageable
      def mailbox
        @mailbox ||= Mailboxer::Mailbox.new(self)
      end

      # Get number of unread messages
      def unread_inbox_count
        mailbox.inbox(unread: true).count
      end

      #Sends a messages, starting a new conversation, with the messageable
      #as originator
      def send_message(recipients, msg_body, subject, sanitize_text=true, attachment=nil, message_timestamp = Time.now)
        convo = Mailboxer::ConversationBuilder.new({
          :subject    => subject,
          :created_at => message_timestamp,
          :updated_at => message_timestamp
        }).build

        message = Mailboxer::MessageBuilder.new({
          :sender       => self,
          :conversation => convo,
          :recipients   => recipients,
          :body         => msg_body,
          :subject      => subject,
          :attachment   => attachment,
          :created_at   => message_timestamp,
          :updated_at   => message_timestamp
        }).build

        message.deliver false, sanitize_text
      end

      #Basic reply method. USE NOT RECOMENDED.
      #Use reply_to_sender, reply_to_all and reply_to_conversation instead.
      def reply(conversation, recipients, reply_body, subject=nil, sanitize_text=true, attachment=nil)
        subject = subject || "#{conversation.subject}"
        response = Mailboxer::MessageBuilder.new({
          :sender       => self,
          :conversation => conversation,
          :recipients   => recipients,
          :body         => reply_body,
          :subject      => subject,
          :attachment   => attachment
        }).build

        response.recipients.delete(self)
        response.deliver true, sanitize_text
      end

      #Replies to the sender of the message in the conversation
      def reply_to_sender(receipt, reply_body, subject=nil, sanitize_text=true, attachment=nil)
        reply(receipt.conversation, receipt.message.sender, reply_body, subject, sanitize_text, attachment)
      end

      #Replies to all the recipients of the message in the conversation
      def reply_to_all(receipt, reply_body, subject=nil, sanitize_text=true, attachment=nil)
        reply(receipt.conversation, receipt.message.recipients, reply_body, subject, sanitize_text, attachment)
      end

      #Replies to all the recipients of the last message in the conversation and untrash any trashed message by messageable
      #if should_untrash is set to true (this is so by default)
      def reply_to_conversation(conversation, reply_body, subject=nil, should_untrash=true, sanitize_text=true, attachment=nil)
        #move conversation to inbox if it is currently in the trash and should_untrash parameter is true.
        if should_untrash && mailbox.is_trashed?(conversation)
          mailbox.receipts_for(conversation).untrash
          mailbox.receipts_for(conversation).mark_as_not_deleted
        end

        reply(conversation, conversation.last_message.recipients, reply_body, subject, sanitize_text, attachment)
      end

      #Mark the object as read for messageable.
      #
      #Object can be:
      #* A Receipt
      #* A Message
      #* A Notification
      #* A Conversation
      #* An array with any of them
      def mark_as_read(obj)
        case obj
        when Mailboxer::Receipt
          obj.mark_as_read if obj.receiver == self
        when Mailboxer::Message, Mailboxer::Notification
          obj.mark_as_read(self)
        when Mailboxer::Conversation
          obj.mark_as_read(self)
        when Array
          obj.map{ |sub_obj| mark_as_read(sub_obj) }
        end
      end

      #Mark the object as unread for messageable.
      #
      #Object can be:
      #* A Receipt
      #* A Message
      #* A Notification
      #* A Conversation
      #* An array with any of them
      def mark_as_unread(obj)
        case obj
        when Mailboxer::Receipt
          obj.mark_as_unread if obj.receiver == self
        when Mailboxer::Message, Mailboxer::Notification
          obj.mark_as_unread(self)
        when Mailboxer::Conversation
          obj.mark_as_unread(self)
        when Array
          obj.map{ |sub_obj| mark_as_unread(sub_obj) }
        end
      end

      #Mark the object as deleted for messageable.
      #
      #Object can be:
      #* A Receipt
      #* A Notification
      #* A Message
      #* A Conversation
      #* An array with any of them
      def mark_as_deleted(obj)
        case obj
          when Mailboxer::Receipt
            return obj.mark_as_deleted if obj.receiver == self
          when Mailboxer::Message, Mailboxer::Notification
            obj.mark_as_deleted(self)
          when Mailboxer::Conversation
            obj.mark_as_deleted(self)
          when Array
            obj.map{ |sub_obj| mark_as_deleted(sub_obj) }
          else
            return nil
        end
      end

      #Mark the object as trashed for messageable.
      #
      #Object can be:
      #* A Receipt
      #* A Message
      #* A Notification
      #* A Conversation
      #* An array with any of them
      def trash(obj)
        case obj
        when Mailboxer::Receipt
          obj.move_to_trash if obj.receiver == self
        when Mailboxer::Message, Mailboxer::Notification
          obj.move_to_trash(self)
        when Mailboxer::Conversation
          obj.move_to_trash(self)
        when Array
          obj.map{ |sub_obj| trash(sub_obj) }
        end
      end

      #Mark the object as not trashed for messageable.
      #
      #Object can be:
      #* A Receipt
      #* A Message
      #* A Notification
      #* A Conversation
      #* An array with any of them
      def untrash(obj)
        case obj
        when Mailboxer::Receipt
          obj.untrash if obj.receiver == self
        when Mailboxer::Message, Mailboxer::Notification
          obj.untrash(self)
        when Mailboxer::Conversation
          obj.untrash(self)
        when Array
          obj.map{ |sub_obj| untrash(sub_obj) }
        end
      end

      def search_messages(query)
        if Mailboxer.search_engine == :pg_search
          Mailboxer::Receipt.search(query).where(receiver_id: self.id).map(&:conversation).uniq
        else
          @search = Mailboxer::Receipt.search do
            fulltext query
            with :receiver_id, self.id
          end
          @search.results.map { |r| r.conversation }.uniq
        end
      end
    end
  end
end
