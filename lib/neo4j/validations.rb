module Neo4j
  module Validations
    extend ActiveSupport::Concern
    include ActiveModel::Validations
    
    def save
      valid?(:save) ? super : false
    end
    
    def destroy
      valid?(:destroy) ? super : false
    end
    
    private
      def create_or_update #:nodoc:
        valid?(:save) ? super : false
      end
  
      def create #:nodoc:
        valid?(:create) ? super : false
      end
  
      def update(*) #:nodoc:
        valid?(:update) ? super : false
      end
  end
end