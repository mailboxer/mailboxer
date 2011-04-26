class Duck < ActiveRecord::Base
  def should_email?(object)
    case object
    when Message
      return false
    when Notification
      return true
    end
  end

  acts_as_messageable
end
