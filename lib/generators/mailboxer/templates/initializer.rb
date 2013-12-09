Mailboxer.setup do |config|

  #Configures if you application uses or not email sending for Notifications and Messages
  config.uses_emails = true

  #Configures the default from for emails sent for Messages and Notifications
  config.default_from = "no-reply@mailboxer.com"

  #Configures the methods needed by mailboxer
  config.email_method = :mailboxer_email
  config.name_method = :name

  #Configures if you use or not a search engine and which one you are using
  #Supported engines: [:solr,:sphinx]
  config.search_enabled = false
  config.search_engine = :solr
end
