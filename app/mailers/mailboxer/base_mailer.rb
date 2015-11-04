class Mailboxer::BaseMailer < ActionMailer::Base
  default :from => Mailboxer.default_from

  private

  def set_subject(container)
    @subject  = container.subject.html_safe? ? container.subject : strip_tags(container.subject)
  end

  def strip_tags(text)
    ::Mailboxer::Cleaner.instance.strip_tags(text)
  end

  def attach_message_attachments
    return unless @message.respond_to?(:attachments)
    @message.attachments.each do |attachment|
      attachments[attachment.send(Mailboxer.attachment_filename_method)] =
        attachment.send(Mailboxer.attachment_file_method)
    end
  end
end
