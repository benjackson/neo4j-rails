require 'neo4j'
require 'neo4j/extensions/reindexer'
require 'active_model'
require 'neo4j/inheritence'
require 'neo4j/attributes'
require 'neo4j/delayed_save'
require 'neo4j/node_creation'
require 'neo4j/callbacks'
require 'neo4j/validations'

module Neo4j
  class Model
    include NodeMixin
    include Inheritence
    include Attributes
    include DelayedSave
    include NodeCreation
    include Validations
    include Callbacks
    include ActiveModel::Conversion
    
    # Override NodeMixin#init_without_node to save the properties for
    # when #save is called.
    def init_without_node(props) # :nodoc:
      raise "Can't use Neo4j::Model with anonymous classes" if self.class.name == ""
      init_props(props)
    end
  
    # Ensure nodes loaded from the database are marked as persisted.
    def init_with_node_with_persistence(java_node)
      init_with_node_without_persistence(java_node)
      @persisted = true
      @_unsaved_props = {}
    end
    
    alias_method_chain :init_with_node, :persistence
  
    class << self # class methods
      def load(*ids)
        result = ids.map {|id| Neo4j.load_node(id) }
        if ids.length == 1
          result.first
        else
          result
        end
      end
    
      def all
        super.nodes
      end
      
      def first
        self.all.first
      end
    
      # Handle Model.find(params[:id])
      def find(*args)
        if args.length == 1 && String === args[0] && args[0].to_i != 0
          load(*args)
        else
          super
        end
      end
    end
  end
end