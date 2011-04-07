Gem::Specification.new do |s|
	s.name = "mailboxer"
	s.version = "0.0.15"
	s.authors = ["Eduardo Casanova Cuesta"]
	s.summary = "Messaging system for rails apps."
	s.description = "A Rails engine that allows any model to act as messageable, permitting it interchange messages with any other messageable model and receive system notifications."
	s.email = "ecasanovac@gmail.com"
	s.homepage = "http://github.com/ging/mailboxer"
	s.files = `git ls-files`.split("\n")

	# Gem dependencies
	#
	# SQL foreign keys
	s.add_runtime_dependency('foreigner', '~> 0.9.1')

	# Development Gem dependencies
	#
	s.add_development_dependency('rails', '~> 3.0.5')
	# Testing database
	s.add_development_dependency('sqlite3-ruby')
	# Debugging
	if RUBY_VERSION < '1.9'
		s.add_development_dependency('ruby-debug', '~> 0.10.3')
	end
	# Specs
	s.add_development_dependency('rspec-rails', '~> 2.5.0')
	# Fixtures
	s.add_development_dependency('factory_girl', '~> 1.3.2')
	# Population
	s.add_development_dependency('forgery', '~> 0.3.6')
	# Integration testing
	s.add_development_dependency('capybara', '~> 0.3.9')

end

