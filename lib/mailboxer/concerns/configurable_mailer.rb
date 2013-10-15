require 'active_support/inflections'

module Concerns
  module ConfigurableMailer

    def get_mailer
      return @mailer if @mailer
      klass = self.class.to_s.sub(/^Mailboxer::/, '')
      method = "#{klass.downcase}_mailer".to_sym
      @mailer = Mailboxer.send(method) ||  "#{klass}Mailer".constantize
    end

  end
end
