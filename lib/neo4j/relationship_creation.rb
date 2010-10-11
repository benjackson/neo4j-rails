module Neo4j
  module RelationshipCreation
    extend ActiveSupport::Concern
    
    included do
      alias_method :create_relationship, :init_with_args
      alias_method_chain :create, :relationship
    end
    
    def create_with_relationship
      #breakpoint
      create_relationship(@_relationship_type, @_start_node, @_end_node)
      props.each_pair {|k,v| @_java_node[k] = v}
      create_without_relationship
    end
  end
end