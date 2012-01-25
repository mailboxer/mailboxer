class Mailboxer::ViewsGenerator < Rails::Generators::Base
  source_root File.expand_path("../../../../app/views", __FILE__)
  
  desc "Copy Mailboxer views into your app"
  def copy_views    
    directory('message_mailer', 'app/views/message_mailer')
    directory('notification_mailer', 'app/views/notification_mailer')
  end
end