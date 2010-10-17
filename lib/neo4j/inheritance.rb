module Neo4j
  module Inheritance
    extend ActiveSupport::Concern
    
    module ClassMethods
      def inherited(subclass) # :nodoc:
        # Make subclasses of each have their own root class/indexer
        subclass.instance_eval do
          def root_class
            self
          end
        end
        
        # index the same properties as this class
        indexer.property_indexer.properties.each do |property|
          subclass.indexer.add_index_on_property(property)
        end
        
        # TODO: index the same relationship properties as this class
      end
    end
  end
end