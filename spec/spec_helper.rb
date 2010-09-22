begin
  require File.expand_path('../../.bundle/environment', __FILE__)
rescue LoadError
  require 'rubygems'
  require 'bundler'
  Bundler.setup
end
Bundler.require :default, :test

require 'spec'
require 'spec/interop/test'
require File.join(File.dirname(__FILE__), 'neo4j', 'shared_model_examples')

# Since we're using spec/interop/test, we might as well add our
# helpers to T::U::TC
class Test::Unit::TestCase
  def self.use_transactions
    before :each do
      txn do
        Neo4j.all_nodes { |n| n.del if n.is_a?(Neo4j::Model) }
      end
      
      Neo4j::Transaction.new
    end

    after :each do
      Neo4j::Transaction.failure
      Neo4j::Transaction.finish
    end
  end

  def txn(&block)
    Neo4j::Transaction.run(&block)
  end

  # HAX: including a module of test_ methods doesn't seem to get them
  # registered, so I'm registering them manually
  def self.include_tests(mod)
    include mod
    mod.instance_methods(false).each do |m|
      example(m, {}) {__send__ m}
    end
  end
end
