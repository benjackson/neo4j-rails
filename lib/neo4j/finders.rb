module Neo4j
  module Finders
    extend ActiveSupport::Concern
    
    module ClassMethods
      def find(*args)
        # Handle Model.find(params[:id])
        if args.length == 1 && String === args[0] && args[0].to_i != 0
          load(*args)
        else
          # find using Lucene, but return the first result (all should be used if all results are required)
          super.first
        end
      end
      
      def first
        self.all.first
      end
    end
  end
end