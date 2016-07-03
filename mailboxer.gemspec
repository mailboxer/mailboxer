lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mailboxer/version'

Gem::Specification.new do |s|
  s.name = "mailboxer"
  s.version = Mailboxer::VERSION

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
  s.license = 'MIT'

  # Gem dependencies
  #

  # Development Gem dependencies
  s.add_runtime_dependency('rails', '>= 4.2.0')
  s.add_runtime_dependency('carrierwave', '>= 0.5.8')

  if RUBY_ENGINE == "rbx" && RUBY_VERSION >= "2.1.0"
    # Rubinius has it's own dependencies
    s.add_runtime_dependency     'rubysl'
    s.add_development_dependency 'racc'
  end
  # Specs
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'rspec-its', '~> 1.1'
  s.add_development_dependency 'rspec-collection_matchers', '~> 1.1'
  s.add_development_dependency('appraisal', '~> 1.0.0')
  s.add_development_dependency('shoulda-matchers', '~> 2')
  s.add_development_dependency('factory_girl', '~> 2.6.0')
  # Population
  s.add_development_dependency('forgery', '>= 0.3.6')
  # Integration testing
  s.add_development_dependency('capybara', '>= 0.3.9')
  # Testing database
  if RUBY_PLATFORM == 'java'
    s.add_development_dependency('jdbc-sqlite3')
    s.add_development_dependency('activerecord-jdbcsqlite3-adapter', '1.3.0.rc1')
  else
    s.add_development_dependency('sqlite3')
  end
end
