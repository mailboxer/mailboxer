module Mailboxer 
  module Models
    autoload :Messageable, 'mailboxer/models/messageable'
  end  
  
  mattr_accessor :default_from
  @@default_from = "no-reply@mailboxer.com"
  mattr_accessor :uses_emails
  @@uses_emails = true
  mattr_accessor :search_enabled
  @@search_enabled = false
  mattr_accessor :search_engine
  @@search_engine = :solr
  mattr_accessor :email_method
  @@email_method = :mailboxer_email
  mattr_accessor :name_method
  @@name_method = :name
  mattr_accessor :notification_mailer
  mattr_accessor :message_mailer

   class << self
    def setup
      yield self
    end
   end
   
end
# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it
require 'mailboxer/engine' 
require 'mailboxer/concerns/configurable_mailer'
