class MailBoxer::AttachmentUploader < CarrierWave::Uploader::Base
  storage :file
end
