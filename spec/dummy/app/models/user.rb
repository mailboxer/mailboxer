class User < ActiveRecord::Base
  acts_as_messageable
  def mailboxer_email(object)
    return email
  end
end
