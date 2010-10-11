module Neo4j
  module Attributes
    extend ActiveSupport::Concern
    
    def attributes=(attrs)
      attrs.each do |k,v|
        @_unsaved_props[k] = v
      end
    end
    
    # return the props without the internal vars
    def attributes
      props.reject { |k, v| k == :_classname || k == :_neo_id }
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