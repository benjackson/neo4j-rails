module Neo4j
  class Model
    include NodeMixin
    include Inheritance
    include Attributes
    include DelayedSave
    include Finders
    include NodeCreation
    include Validations
    include Callbacks
    include XML
    include ActiveModel::Serialization
    include ActiveModel::Conversion
    
    # make properties inheritable but overwritable by subclasses, rather than the same across all classes
    class_inheritable_hash :properties_info, {}
    self.properties_info = {}
    
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
      
      def all(query = nil, &block)
        if query.blank?
          # Return all nodes
          index_node = IndexNode.instance
          index_node.rels.outgoing(self).nodes
        else
          # find using Lucene
          indexer.find(query, block)
        end
      end
      
      # have to change this method because I've changed the way #all works
      def update_index
        all.each do |n|
          n.update_index
        end
      end
    end
  end
end