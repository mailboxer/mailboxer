class Mailboxer::ReceiptBuilder

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def build
    Mailboxer::Receipt.new.tap do |receipt|
      receipt.notification = notification
      receipt.is_read      = is_read
      receipt.receiver     = receiver
      receipt.mailbox_type = mailbox_type

      receipt.created_at   = created_at if created_at
      receipt.updated_at   = updated_at if updated_at
    end
  end

  private

  def notification
    params.fetch(:notification)
  end

  def is_read
    params.fetch(:is_read, false)
  end

  def receiver
    params.fetch(:receiver)
  end

  def mailbox_type
    params.fetch(:mailbox_type, 'inbox')
  end

  def created_at
    params.fetch(:created_at, nil)
  end

  def updated_at
    params.fetch(:updated_at, nil)
  end
end
