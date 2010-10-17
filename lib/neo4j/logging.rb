require 'neo4j/model'
require 'neo4j/rails_relationship'

module Neo4j
  module Logging
    extend ActiveSupport::Concern
    
    mattr_accessor :logger
    
    included do
      [:create, :update, :destroy].each do |m|
        alias_method_chain m, :logging
      end
    end
    
    def create_with_logging
      result = create_without_logging
      logger.info "#create #{self.class} #{attributes.inspect}" if logger && result
      result
    end
    
    def update_with_logging
      result = update_without_logging
      logger.info "#update #{self.class} #{attributes.inspect}" if logger && result
      result
    end
    
    def destroy_with_logging
      logger.info "#destroy #{self.class} #{attributes.inspect}"
      destroy_without_logging
    end
  end
end

Neo4j::Model.send(:include, Neo4j::Logging)
Neo4j::RailsRelationship.send(:include, Neo4j::Logging)