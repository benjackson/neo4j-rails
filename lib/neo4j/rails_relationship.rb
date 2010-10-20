module Neo4j
  class RailsRelationship
    include RelationshipMixin
    include Inheritance
    include Attributes
    include DelayedSave
    include Finders
    include RelationshipCreation
    include Validations
    include Callbacks
    include XML
    include ActiveModel::Serialization
    include ActiveModel::Conversion
    
    validates :start_node, :presence => true, :persisted => true
    validates :end_node, :presence => true, :persisted => true
    validates :relationship_type, :presence => true
    
    # overwrite the RelationshipMixin init_with_args to extract the start and end node
    def init_with_args(*args)
      options = args.extract_options!
      @_relationship_type = options[:type]
      @_start_node = options[:start_node]
      @_end_node = options[:end_node]
      init_props(options.reject {|k,v| k == :type || k == :start_node || k == :end_node})
      initialize_relationship if respond_to?(:initialize_relationship)
    end
    
    def init_with_rel_with_persistence(rel)
      init_with_rel_without_persistence(rel)
      @persisted = true
      @_unsaved_props = {}
    end
    
    alias_method_chain :init_with_rel, :persistence
    
    def relationship_type
      persisted? ? super : @_relationship_type
    end
    
    def start_node
      persisted? ? super : @_start_node
    end
    
    def end_node
      persisted? ? super : @_end_node
    end
    
    def relationship_type=(relationship_type)
      if persisted?
        super
      else
        @_relationship_type = relationship_type
      end
    end
    
    def start_node=(node)
      if persisted?
        super
      else
        @_start_node = node
      end
    end
    
    def end_node=(node)
      if persisted?
        super
      else
        @_end_node = node
      end
    end
    
    def internal_r
      id 
    end
    
    class << self # class methods
      def load(*ids)
        result = ids.map {|id| Neo4j.load_rel(id) }
        if ids.length == 1
          result.first
        else
          result
        end
      end
      
      def all(*args)
        if args.empty?
          # Return all rels
          super
        else
          # find using Lucene
          indexer.find(*args)
        end
      end
    end
  end
end