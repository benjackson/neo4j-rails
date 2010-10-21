module Neo4j
  module Attributes
    extend ActiveSupport::Concern
    
    def attributes=(attrs)
      @_unsaved_props.merge!(attrs)
    end
    
    # return the props without the internal vars
    def attributes
      ret = {}
      self.class.properties_info.each_key { |k| ret[k] = respond_to?(k) ? send(k) : self[k] }
      ret
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