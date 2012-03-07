# Database foreign keys
require 'foreigner'
require 'carrierwave'
begin 
  require 'sunspot_rails'
  Logger.new(STDOUT).debug 'The sunspot_rails gem is present. Loading it into mailboxer. You can know use Solr search engine.'
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