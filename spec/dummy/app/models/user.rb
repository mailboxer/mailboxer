class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable
  acts_as_messageable
  def mailboxer_email(object)
    return email
  end
end
