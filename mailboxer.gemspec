
Gem::Specification.new do |s|
  s.name = "mailboxer"
  s.version = "0.0.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eduardo Casanova Cuesta"]
  s.date = %q{2011-03-23}
  s.description = %q{A Rails engine that allows any model to act as messageable, permitting it interchange messages with any other messageable model. }
  s.email = %q{ecasanovac@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.homepage = %q{http://github.com/ging/mailboxer}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Messaging system for rails apps.}
  s.files = `git ls-files`.split("\n")
  
  s.add_dependency(%q<rails>, ["= 3.0.5"])
  s.add_development_dependency(%q<sqlite3-ruby>, [">= 0"])
  if RUBY_VERSION < '1.9'
    s.add_development_dependency('ruby-debug', '~> 0.10.3')
  end
  s.add_development_dependency(%q<rspec-rails>, [">= 2.0.0.beta"])
  s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
  s.add_development_dependency(%q<jeweler>, ["~> 1.5.0.pre3"])
  s.add_development_dependency(%q<rcov>, [">= 0"])
  s.add_development_dependency('factory_girl', '~> 1.3.2')
  s.add_development_dependency('forgery', '~> 0.3.6')
  s.add_development_dependency('capybara', '~> 0.3.9')
end

