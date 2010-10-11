# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{neo4j-rails}
  s.version = "0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Sieger"]
  s.date = %q{2010-06-06}
  s.description = %q{Adapts Neo4j for Rails 3 apps using ActiveModel}
  s.email = ["nick@nicksieger.com"]
  s.files = ["lib/neo4j-rails.rb", "lib/neo4j/delayed_save.rb", "lib/neo4j/model.rb", "lib/neo4j/rails_relationship.rb", "lib/neo4j/attributes.rb", "lib/neo4j/callbacks.rb", "lib/neo4j/node_creation.rb", "lib/neo4j/persistance_validator.rb", "lib/neo4j/relationship_creation.rb", "lib/neo4j/validations.rb", "lib/neo4j/rails.rb", "lib/neo4j/railtie.rb", "lib/neo4j/transaction_management.rb", "lib/neo4j-rails/version.rb", "spec/spec_helper.rb", "spec/neo4j/model_spec.rb", "spec/neo4j/rails_relationship_spec.rb", "spec/support/shared_model_examples.rb", "Gemfile", "neo4j-rails.gemspec", "History.txt", "LICENSE.txt", "Rakefile", "README.markdown"]
  s.homepage = %q{http://jruby.org}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Neo4j adapter for Rails 3}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 3.0.0.beta2"])
      s.add_runtime_dependency(%q<neo4j>, [">= 0.4.3"])
    else
      s.add_dependency(%q<rails>, [">= 3.0.0.beta2"])
      s.add_dependency(%q<neo4j>, [">= 0.4.3"])
    end
  else
    s.add_dependency(%q<rails>, [">= 3.0.0.beta2"])
    s.add_dependency(%q<neo4j>, [">= 0.4.3"])
  end
end
