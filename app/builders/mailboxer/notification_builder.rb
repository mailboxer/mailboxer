class Mailboxer::NotificationBuilder < Mailboxer::BaseBuilder

  private

  def fields
    %w(body subject recipients notified_object notification_code)
  end

  def klass
    Mailboxer::Notification
  end

  def notified_object
    params.fetch(:notified_object, nil)
  end

  def notification_code
    params.fetch(:notification_code, nil)
  end
end
