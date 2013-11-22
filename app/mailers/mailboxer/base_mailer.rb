class Mailboxer::BaseMailer < ActionMailer::Base
  default :from => Mailboxer.default_from

  private

  def set_subject(container)
    @subject  = container.subject.html_safe? ? container.subject : strip_tags(container.subject)
  end

  def strip_tags(text)
    ::Mailboxer::Cleaner.instance.strip_tags(text)
  end

end
