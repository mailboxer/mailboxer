class Mailboxer::ReceiptBuilder < Mailboxer::BaseBuilder

  private

  def fields
    %w(notification is_read receiver mailbox_type
      created_at updated_at)
  end

  def klass
    Mailboxer::Receipt
  end

  def is_read
    params.fetch(:is_read, false)
  end

  def mailbox_type
    params.fetch(:mailbox_type, 'inbox')
  end
end
