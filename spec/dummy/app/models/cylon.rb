class Cylon < ActiveRecord::Base
  def should_email?(object)
    return false
  end

  acts_as_messageable
end
