module Neo4j
  module Attributes
    extend ActiveSupport::Concern
    
    def attributes=(attrs)
      @_unsaved_props.merge!(attrs)
    end
    
    # return the props without the internal vars
    def attributes
      ret = {}
      self.class.properties_info.merge(@_unsaved_props).merge(props).each_key do |k|
        sym = k.to_sym
        unless k.to_s[0,1] == "_"
          ret[sym] = respond_to?(sym) ? send(sym) : self[sym]
        end
      end
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