module Mailboxer
  module Models
    module Messageable
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        #Converts the model into messageable allowing it to interchange messages and
        #receive notifications
        def acts_as_messageable
          has_many :messages, :as => :sender
          has_many :receipts, :order => 'created_at DESC', :dependent => :destroy, :as => :receiver

          include Mailboxer::Models::Messageable::InstanceMethods
        end
      end

      module InstanceMethods
          eval <<-EOM
           #Returning any kind of identification you want for the model
           def #{Mailboxer.name_method}
             super
           rescue NameError
             return "You should add method :#{Mailboxer.name_method} in your Messageable model"
           end

           #Returning the email address of the model if an email should be sent for this object (Message or Notification).
           #If no mail has to be sent, return nil.
           def #{Mailboxer.email_method}(object)
             super
           rescue NameError
             return "You should add method :#{Mailboxer.email_method} in your Messageable model"
           end
           EOM
        #Gets the mailbox of the messageable
        def mailbox
          @mailbox = Mailbox.new(self) if @mailbox.nil?
          @mailbox.type = :all
          return @mailbox
        end

        #Sends a notification to the messageable
        def notify(subject,body,obj = nil,sanitize_text=true,notification_code=nil)
          return Notification.notify_all([self],subject,body,obj,sanitize_text,notification_code)
        end

        #Sends a messages, starting a new conversation, with the messageable
        #as originator
        def send_message(recipients, msg_body, subject, sanitize_text=true, attachment=nil)
          convo = Conversation.new({:subject => subject})
          message = messages.new({:body => msg_body, :subject => subject, :attachment => attachment})
          message.conversation = convo
          message.recipients = recipients.is_a?(Array) ? recipients : [recipients]
          message.recipients = message.recipients.uniq
          return message.deliver false,sanitize_text
        end

        #Basic reply method. USE NOT RECOMENDED.
        #Use reply_to_sender, reply_to_all and reply_to_conversation instead.
        def reply(conversation, recipients, reply_body, subject=nil, sanitize_text=true, attachment=nil)
          subject = subject || "RE: #{conversation.subject}"
          response = messages.new({:body => reply_body, :subject => subject, :attachment => attachment})
          response.conversation = conversation
          response.recipients = recipients.is_a?(Array) ? recipients : [recipients]
          response.recipients = response.recipients.uniq
          response.recipients.delete(self)
          return response.deliver true, sanitize_text
        end

        #Replies to the sender of the message in the conversation
        def reply_to_sender(receipt, reply_body, subject=nil, sanitize_text=true, attachment=nil)
          return reply(receipt.conversation, receipt.message.sender, reply_body, subject, sanitize_text, attachment)
        end

        #Replies to all the recipients of the message in the conversation
        def reply_to_all(receipt, reply_body, subject=nil, sanitize_text=true, attachment=nil)
          return reply(receipt.conversation, receipt.message.recipients, reply_body, subject, sanitize_text, attachment)
        end

        #Replies to all the recipients of the last message in the conversation and untrash any trashed message by messageable
        #if should_untrash is set to true (this is so by default)
        def reply_to_conversation(conversation, reply_body, subject=nil, should_untrash=true, sanitize_text=true, attachment=nil)
          #move conversation to inbox if it is currently in the trash and should_untrash parameter is true.
          if should_untrash && mailbox.is_trashed?(conversation)
            mailbox.receipts_for(conversation).untrash
          end
          return reply(conversation, conversation.last_message.recipients, reply_body, subject, sanitize_text, attachment)
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
          when Receipt
            return obj.mark_as_read if obj.receiver == self
          when Message, Notification
            obj.mark_as_read(self)
          when Conversation
            obj.mark_as_read(self)
          when Array
            obj.map{ |sub_obj| mark_as_read(sub_obj) }
          else
            return nil
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
          when Receipt
            return obj.mark_as_unread if obj.receiver == self
          when Message, Notification
            obj.mark_as_unread(self)
          when Conversation
            obj.mark_as_unread(self)
          when Array
            obj.map{ |sub_obj| mark_as_unread(sub_obj) }
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
          when Receipt
            return obj.move_to_trash if obj.receiver == self
          when Message, Notification
            obj.move_to_trash(self)
          when Conversation
            obj.move_to_trash(self)
          when Array
            obj.map{ |sub_obj| trash(sub_obj) }
          else
          return nil
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
          when Receipt
            return obj.untrash if obj.receiver == self
          when Message, Notification
            obj.untrash(self)
          when Conversation
            obj.untrash(self)
          when Array
            obj.map{ |sub_obj| untrash(sub_obj) }
          else
          return nil
          end
        end

        def search_messages(query)
          @search = Receipt.search do
            fulltext query
            with :receiver_id, self.id
          end

          @search.results.map { |r| r.conversation }.uniq
        end
      end
    end
  end
end
