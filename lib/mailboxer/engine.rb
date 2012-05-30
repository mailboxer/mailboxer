# Database foreign keys
require 'foreigner'
require 'carrierwave'
begin 
  require 'sunspot_rails'
rescue LoadError
end

module Mailboxer
  class Engine < Rails::Engine
    
    initializer "mailboxer.models.messageable" do
      ActiveSupport.on_load(:active_record) do
        include Mailboxer::Models::Messageable
      end
    end
  end
end