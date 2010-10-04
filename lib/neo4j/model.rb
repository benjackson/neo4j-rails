require 'neo4j'
require 'neo4j/extensions/reindexer'
require 'active_model'
require 'neo4j/delayed_save'
require 'neo4j/callbacks'
require 'neo4j/validations'

module Neo4j
  class Model
    include NodeMixin
    include DelayedSave
    include Validations
    include Callbacks
    include ActiveModel::Conversion
    
    class RecordInvalidError < RuntimeError
      attr_reader :record
      def initialize(record)
        @record = record
        super(@record.errors.full_messages.join(", "))
      end
    end
    
    def persisted?
      @persisted
    end
  
    def read_attribute_for_validation(key)
      self[key]
    end
  
    def attributes=(attrs)
      attrs.each do |k,v|
        unless k == "_neo_id"           # ignore the _neo_id when setting attributes from a bunch of attrs from another model
          if respond_to?("#{k}=")
            send("#{k}=", v)
          else
            self[k] = v
          end
        end
      end
    end
    
    def props
      # allow access to props when the java object isn't there
      persisted? ? super : @_unsaved_props
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
  
    alias_method :destroy, :del
  
    def save!
      unless save
        raise RecordInvalidError.new(self)
      end
    end
  
    class << self # class methods
      def primary_key
        'id'
      end
    
      def load(*ids)
        result = ids.map {|id| Neo4j.load_node(id) }
        if ids.length == 1
          result.first
        else
          result
        end
      end
    
      def all
        super.nodes
      end
      
      def first
        self.all.first
      end
    
      # Handle Model.find(params[:id])
      def find(*args)
        if args.length == 1 && String === args[0] && args[0].to_i != 0
          load(*args)
        else
          super
        end
      end
    
      def create(*args)
        new(*args).tap {|model| model.save }
      end
      
      def create!(*args)
        new(*args).tap {|model| model.save! }
      end
    
      def inherited(subc) # :nodoc:
        # Make subclasses of Neo4j::Model each have their own root class/indexer
        subc.instance_eval do
          def root_class
            self
          end
        end
      end
    end
  end
end