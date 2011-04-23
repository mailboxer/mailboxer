class User < ActiveRecord::Base
  def should_email?(object)
    true
  end

  acts_as_messageable
end