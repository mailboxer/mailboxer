require 'active_support/inflections'

module Concerns
  module ConfigurableMailer

    def get_mailer
      return @mailer if @mailer
      method = "#{self.class.to_s.downcase}_mailer".to_sym
      @mailer = Mailboxer.send(method) ||  "#{self.class}Mailer".constantize
    end

  end
end
