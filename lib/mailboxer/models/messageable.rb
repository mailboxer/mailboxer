module Mailboxer 
  module Models 
    module Messageable       
      
      def self.included(mod)
        mod.extend(ClassMethods)
      end
      
      module ClassMethods
        
        def acts_as_messageable          
          has_many :mailboxer_messages
          has_many :mailboxer_mails, :order => 'created_at DESC', :dependent => :delete_all    
          
          include Mailboxer::Models::Messageable::InstanceMethods
        end
      end
      
      module InstanceMethods
        
        def mailbox
          @mailbox = MailboxerMailbox.new(self) if @mailbox.nil?
          @mailbox.type = :all
          return @mailbox
        end
        
        def send_message(recipients, msg_body, subject = '')
          convo = MailboxerConversation.create({:subject => subject})
          message = MailboxerMessage.create({:sender => self, :mailboxer_conversation => convo,  :body => msg_body, :subject => subject})
          message.recipients = recipients.is_a?(Array) ? recipients : [recipients]
          message.deliver(:inbox)
          return mailbox[:sentbox] << message
        end
        
        def reply(conversation, recipients, reply_body, subject = nil)
          return nil if(reply_body.blank?)
          subject = subject || "RE: #{conversation.subject}"
          response = MailboxerMessage.create({:sender => self, :mailboxer_conversation => conversation, :body => reply_body, :subject => subject})
          response.recipients = recipients.is_a?(Array) ? recipients : [recipients]
          response.recipients.delete(self)
          response.deliver(:inbox)
          return mailbox[:sentbox] << response
        end
        
        def reply_to_sender(mail, reply_body, subject = nil)
          return reply(mail.mailboxer_conversation, mail.mailboxer_message.sender, reply_body, subject)
        end
        
        def reply_to_all(mail, reply_body, subject = nil)
          msg = mail.mailboxer_message
          recipients = msg.get_recipients
          return reply(mail.mailboxer_conversation, recipients, reply_body, subject)
        end
        
        def reply_to_conversation(conversation, reply_body, subject = nil)
          #move conversation to inbox if it is currently in the trash - doesnt make much sense replying to a trashed convo.
          if(mailbox.is_trashed?(conversation))
            mailbox.mail.conversation(conversation).untrash
          end
          #remove self from recipients unless you are the originator of the convo
          recipients = conversation.get_recipients
          if(conversation.originator != self)
            recipients.delete(self)
            if(!recipients.include?(conversation.originator))
              recipients << conversation.originator
            end
          end
          return reply(conversation,recipients, reply_body, subject)
        end 
        
        def read_mail(mail)          
          return mail.mark_as_read if mail.receiver == self
        end 
        
        def unread_mail(mail)
          return mail.mark_as_unread if mail.receiver == self
        end
        
        def read_conversation(conversation, options = {})
          mails = conversation.mailboxer_mails.receiver(self)
          mails_clone = mails.clone
          
          mails.each do |mail|
            mail.mark_as_read
          end
          
          return mails_clone
        end
      end
    end
  end
end