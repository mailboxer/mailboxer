module Mailboxer 
  module Models
    autoload :Messageable, 'mailboxer/models/messageable'
  end  
end
# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it
require 'mailboxer/engine' 