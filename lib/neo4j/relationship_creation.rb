module Neo4j
  module RelationshipCreation
    extend ActiveSupport::Concern
    
    included do
      alias_method :create_relationship, :init_with_args
      alias_method_chain :create, :relationship
      alias_method_chain :update, :relationship
    end
    
    def create_with_relationship
      create_relationship(@_relationship_type, @_start_node, @_end_node)
      props.each_pair {|k,v| @_java_node[k] = v}
      create_without_relationship
    end
    
    def update_with_relationship
      # TODO: currently, it's still called 'java_node' in the relationship mixin
      @_unsaved_props.each {|k,v| @_java_node[k] = v unless k.to_s == "_neo_id" || k.to_s == "_classname" }
      update_without_relationship
    end
  end
end