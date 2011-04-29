module Mailboxer 
  module Models
    autoload :Messageable, 'mailboxer/models/messageable'
  end  
  module Exceptions
    autoload :NotCompliantModel, 'mailboxer/exceptions'
  end  
  
  mattr_accessor :default_from
  mattr_accessor :uses_emails
  
   class << self
    def setup
      yield self
    end
   end
   
end
# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it
require 'mailboxer/engine' 