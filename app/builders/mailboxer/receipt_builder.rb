class Mailboxer::ReceiptBuilder < Mailboxer::BaseBuilder

  protected

  def klass
    Mailboxer::Receipt
  end

  def mailbox_type
    params.fetch(:mailbox_type, 'inbox')
  end

end
