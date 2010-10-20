module Neo4j
  module Attributes
    extend ActiveSupport::Concern
    
    def attributes=(attrs)
      @_unsaved_props.merge!(attrs)
    end
    
    # return the props without the internal vars
    def attributes
      @_unsaved_props.merge(props).reject { |k, v| k == "_classname" || k == "_neo_id" }
    end
    
    def update_attributes(attributes)
      self.attributes = attributes
      save
    end
    
    def update_attributes!(attributes)
      self.attributes = attributes
      save!
    end
  end
end