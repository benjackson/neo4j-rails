module Neo4j
  module Validations
    extend ActiveSupport::Concern
    include ActiveModel::Validations
    
    included do
      [:create_or_update, :create, :update].each do |method|
        alias_method_chain method, :validation
      end
    end
    
    def read_attribute_for_validation(key)
      respond_to?(key) ? send(key) : self[key]
    end
    
    private
      def create_or_update_with_validation #:nodoc:
        valid?(:save) ? create_or_update_without_validation : false
      end
  
      def create_with_validation #:nodoc:
        valid?(:create) ? create_without_validation : false
      end
  
      def update_with_validation(*) #:nodoc:
        valid?(:update) ? update_without_validation : false
      end
  end
end