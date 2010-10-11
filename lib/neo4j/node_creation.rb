module Neo4j
  module NodeCreation
    extend ActiveSupport::Concern
    
    included do
      alias_method :create_node, :init_without_node
      alias_method_chain :create, :node
    end
    
    def create_with_node
      create_node(@_unsaved_props)
      create_without_node
    end
  end
end