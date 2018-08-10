class Mailboxer::Attachment < ActiveRecord::Base
  self.table_name = :mailboxer_attachments

  mount_uploader :file, Mailboxer::AttachmentUploader
end