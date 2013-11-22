require 'singleton'

module Mailboxer
  class Cleaner
    include Singleton
    include ActionView::Helpers::SanitizeHelper

  end
end
