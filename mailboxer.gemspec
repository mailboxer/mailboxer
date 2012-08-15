Gem::Specification.new do |s|
  s.name = "mailboxer"
  s.version = "0.8.0"
  s.authors = ["Eduardo Casanova Cuesta"]
  s.summary = "Messaging system for rails apps."
  s.description = "A Rails engine that allows any model to act as messageable, adding the ability to exchange messages " +
                   "with any other messageable model, even different ones. It supports the use of conversations with " +
                   "two or more recipients to organize the messages. You have a complete use of a mailbox object for " + 
                   "each messageable model that manages an inbox, sentbox and trash for conversations. It also supports " + 
                   "sending notifications to messageable models, intended to be used as system notifications."
  s.email = "ecasanovac@gmail.com"
  s.homepage = "https://github.com/ging/mailboxer"
  s.files = `git ls-files`.split("\n")

  # Gem dependencies
  #
  # SQL foreign keys
  s.add_runtime_dependency('foreigner', '>= 0.9.1')

  # Development Gem dependencies
  s.add_runtime_dependency('rails', '> 3.0.0')
  s.add_runtime_dependency('carrierwave', '>= 0.5.8')
  # Debugging
  if RUBY_VERSION < '1.9'
    s.add_development_dependency('ruby-debug', '>= 0.10.3')
  end
  # Specs
  s.add_development_dependency('rspec-rails', '>= 2.6.1')
  # Fixtures
  #if RUBY_VERSION >= '1.9.2'
   # s.add_development_dependency('factory_girl', '>= 3.0.0')
  #else
    #s.add_development_dependency('factory_girl', '~> 2.6.0')
  #end
  s.add_development_dependency('factory_girl', '~> 2.6.0')
  # Population
  s.add_development_dependency('forgery', '>= 0.3.6')
  # Integration testing
  s.add_development_dependency('capybara', '>= 0.3.9')
  # Testing database
  s.add_development_dependency('sqlite3-ruby') unless RUBY_PLATFORM == 'java'
  s.add_development_dependency('jdbc-sqlite3') if RUBY_PLATFORM == 'java'
  s.add_development_dependency('activerecord-jdbcsqlite3-adapter') if RUBY_PLATFORM == 'java'
end
