class Cylon < ActiveRecord::Base
  acts_as_messageable
    
  def should_email?(object)
    return false
  end
end
