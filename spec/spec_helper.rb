begin
  require File.expand_path('../../.bundle/environment', __FILE__)
rescue LoadError
  require 'rubygems'
  require 'bundler'
  Bundler.setup
end
Bundler.require :default, :test

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  
  config.before(:suite, :type => :neo4j_model) do
    #Neo4j.clear_all_nodes
  end
  
  config.before(:each, :type => :neo4j_transaction) do
    Neo4j::Transaction.new
  end
  
  config.after(:each, :type => :neo4j_transaction) do
    Neo4j::Transaction.failure
    Neo4j::Transaction.finish
  end
end