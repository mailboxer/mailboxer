module Mailboxer
  module Attachable
    extend ActiveSupport::Concern

    included do
      if Mailboxer.uses_multiple_attachments
        has_many :attachments, class_name: 'Mailboxer::Attachment', foreign_key: :notification_id,
                 dependent: :destroy

        define_method :attachment_identifier do
          puts 'In attachment identifier'
          return '' if self.attachments.blank?
          # Can't use filename because of issue https://github.com/carrierwaveuploader/carrierwave/issues/253
          self.attachments.last.file.path.split('/').last
        end

        #This method is defined so that Message builder works with
        #multiple attachments. It uses attachment= method.
        define_method :attachment= do |attached_files|
          attached_files = [attached_files] unless attached_files.kind_of? Array
          self.attachments.destroy # Replacing old attachments with new ones
          attached_files.each do |file|
            self.attachments << Mailboxer::Attachment.new(file: file)
          end
        end

        define_method :attachment do
          self.attachments.last
        end
      else
        attr_accessible :attachment if Mailboxer.protected_attributes?
        mount_uploader :attachment, Mailboxer::AttachmentUploader
      end
    end
  end
end
