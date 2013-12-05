class Mailboxer::AttachmentUploader < CarrierWave::Uploader::Base
  storage :file
end
