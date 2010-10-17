require 'rails/railtie'
require 'neo4j/transaction_management'

module Neo4j
  class Railtie < Rails::Railtie
    config.neo4j = ActiveSupport::OrderedOptions.new
    config.lucene = ActiveSupport::OrderedOptions.new

    initializer "neo4j.tx" do |app|
      app.config.middleware.use Neo4j::TransactionManagement
    end

    initializer "neo4j.logger" do |app|
      if app.config.neo4j.logger
        require 'neo4j/logging'
        Neo4j::Logging.logger = (app.config.neo4j.logger == :rails) ? Rails.logger : app.config.neo4j.logger
      end
    end
    
    # Starting Neo after :load_config_initializers allows apps to
    # register migrations in config/initializers
    initializer "neo4j.start", :after => :load_config_initializers do |app|
      Neo4j::Config.setup.merge!(app.config.neo4j.to_hash)
      Lucene::Config.setup.merge!(app.config.lucene.to_hash)
      Neo4j.start
    end
  end
end
