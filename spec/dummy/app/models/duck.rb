class Duck < ActiveRecord::Base
  acts_as_messageable
  
  def should_email?(object)
    case object
    when Message
      return false
    when Notification
      return true
    end
  end
end
