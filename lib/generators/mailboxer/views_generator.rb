class Mailboxer::ViewsGenerator < Rails::Generators::Base
  source_root File.expand_path("../../../../app/views/mailboxer", __FILE__)

  desc "Copy Mailboxer views into your app"
  def copy_views
    directory('message_mailer', 'app/views/mailboxer/message_mailer')
    directory('notification_mailer', 'app/views/mailboxer/notification_mailer')
  end
end
