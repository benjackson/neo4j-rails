module Neo4j
  module NodeCreation
    extend ActiveSupport::Concern
    
    included do
      alias_method :create_node, :init_without_node
      alias_method_chain :create, :node
      alias_method_chain :update, :node
    end
    
    def create_with_node
      create_node(@_unsaved_props)
      create_without_node
    end
    
    def update_with_node
      @_unsaved_props.each {|k,v| @_java_node[k] = v unless k.to_s == "_neo_id" || k.to_s == "_classname" }
      update_without_node
    end
  end
end