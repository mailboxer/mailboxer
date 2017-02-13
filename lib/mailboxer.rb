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
  mattr_accessor :notify_method
  @@notify_method = :notify
  mattr_accessor :subject_max_length
  @@subject_max_length = 255
  mattr_accessor :body_max_length
  @@body_max_length = 32000
  mattr_accessor :notification_mailer
  mattr_accessor :message_mailer
  mattr_accessor :custom_deliver_proc

  class << self
    def setup
      yield self
    end

    def protected_attributes?
      defined?(ProtectedAttributes)
    end
  end

end
# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it
require 'mailboxer/engine'
require 'mailboxer/cleaner'
require 'mailboxer/mail_dispatcher'
require 'mailboxer/recipient_filter'
