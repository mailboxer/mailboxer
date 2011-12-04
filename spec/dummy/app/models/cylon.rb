class Cylon < ActiveRecord::Base
  acts_as_messageable
  def mailboxer_email(object)
    return nil
  end
end

