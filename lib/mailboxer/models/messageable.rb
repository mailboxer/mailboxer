module Mailboxer
	module Models
		module Messageable
			def self.included(mod)
				mod.extend(ClassMethods)
			end

			module ClassMethods
				def acts_as_messageable
					has_many :messages
					has_many :receipts, :order => 'created_at DESC', :dependent => :delete_all

					include Mailboxer::Models::Messageable::InstanceMethods
				end
			end

			module InstanceMethods
			  
			  ################################### MAILBOXES
			  
				def mailbox
					@mailbox = Mailbox.new(self) if @mailbox.nil?
					@mailbox.type = :all
					return @mailbox
				end
				
				################################### NOTIFICATIONS
				
				def notify(subject,body)
          notification = Notification.new({:body => body, :subject => subject})
          notification.recipients = [self]
          return notification.deliver				  
				end
				
				################################### MESSAGES

				def send_message(recipients, msg_body, subject)
					convo = Conversation.new({:subject => subject})
					message = Message.new({:sender => self, :conversation => convo,  :body => msg_body, :subject => subject})
					message.recipients = recipients.is_a?(Array) ? recipients : [recipients]
					message.recipients = message.recipients.uniq
					return message.deliver
				end

				def reply(conversation, recipients, reply_body, subject = nil)
					subject = subject || "RE: #{conversation.subject}"
					response = Message.new({:sender => self, :conversation => conversation, :body => reply_body, :subject => subject})
					response.recipients = recipients.is_a?(Array) ? recipients : [recipients]					
					response.recipients = response.recipients.uniq
					response.recipients.delete(self)
					return response.deliver(true)
				end

				def reply_to_sender(receipt, reply_body, subject = nil)
					return reply(receipt.conversation, receipt.notification.sender, reply_body, subject)
				end

				def reply_to_all(receipt, reply_body, subject = nil)
					return reply(receipt.conversation, receipt.notification.recipients, reply_body, subject)
				end

				def reply_to_conversation(conversation, reply_body, subject = nil)
					#move conversation to inbox if it is currently in the trash - doesnt make much sense replying to a trashed convo.
					if(mailbox.is_trashed?(conversation))
						mailbox.receipts.conversation(conversation).untrash
					end
					#remove self from recipients unless you are the originator of the convo
					recipients = conversation.last_message.recipients
					if(conversation.originator != self)
						recipients.delete(self)
						if(!recipients.include?(conversation.originator))
						recipients << conversation.originator
						end
					end
					return reply(conversation,recipients, reply_body, subject)
				end

				def read_message(obj)
					if obj.class.to_s.eql? 'Receipt'
						return obj.mark_as_read if obj.receiver == self
					elsif obj.class.to_s.eql? 'Message'
						receipts = obj.receipts.receiver(self)
						return receipts.mark_as_read
					end
					return nil
				end

				def unread_message(obj)
					if obj.class.to_s.eql? 'Receipt'
						return obj.mark_as_unread if obj.receiver == self
					elsif obj.class.to_s.eql? 'Message'
						receipts = obj.receipts.receiver(self)
						return receipts.mark_as_unread
					end
					return nil
				end
				
				
			end
		end
	end
end