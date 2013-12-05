class Mailboxer::NotificationBuilder < Mailboxer::BaseBuilder

  private

  def fields
    %w(body subject recipients notified_object notification_code)
  end

  def klass
    Mailboxer::Notification
  end
end
