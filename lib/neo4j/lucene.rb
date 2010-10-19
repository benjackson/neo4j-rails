module Neo4j
  class IndexNode
    class << self
      # reindex all nodes on startup
      def on_neo_started_with_reindex(neo_instance)
        on_neo_started_without_reindex(neo_instance)
        
        Neo4j::Transaction.run do
          Neo4j.all_nodes do |node|
            node.update_index if node.respond_to?(:update_index)
          end
        end
      end
      
      alias_method_chain :on_neo_started, :reindex
    end
  end
end