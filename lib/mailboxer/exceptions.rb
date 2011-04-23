module Mailboxer
  module Exceptions
    #Mailboxer::Exceptions::NotCompliantModel is raised when your model with acts_as_messageable
    #method is not compliant with the requirements for acting as messageable.
    #
    #These requirements are:
    #* <b>"name" method</b>: Returning any kind of indentification you want for the model
    #* <b>"email" method</b>: Returning the email address of the model. 
    #* <b>"should_email?(object)" method</b>: Returning whether an email should be sent for this object (Message or Notification)
    class NotCompliantModel < RuntimeError; end   
  end
end