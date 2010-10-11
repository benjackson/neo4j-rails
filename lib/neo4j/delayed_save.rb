# Extension to Neo4j::NodeMixin to delay creating/updating properties
# until #save is called.
module Neo4j
  module DelayedSave
    extend ActiveSupport::Concern
    
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
      
    def props
      # allow access to props when the java object isn't there
      persisted? ? super : @_unsaved_props
    end
      
    def init_props(props)
      @_unsaved_props = props || {}
      @persisted = false
    end
  
    # Delegate property access to temporary properties first
    def [](key)
      if @_unsaved_props.has_key?(key)
        @_unsaved_props[key]
      elsif @_java_node
        @_java_node[key]
      end
    end
  
    # Delegate property write to temporary properties
    def []=(key, value)
      @_unsaved_props[key] = value
    end
  
    def reload(*)
      @_unsaved_props.clear
      self
    end
    alias_method :reset, :reload
  
    def save(*)
      create_or_update
    end
    
    def save!
      unless save
        raise RecordInvalidError.new(self)
      end
    end
    
    def del
      super if persisted?
    end
    
    alias_method :destroy, :del
    
    def id
      persisted? ? neo_id : nil
    end
    
    module ClassMethods
      def primary_key
        'id'
      end
      
      def create(*args)
        new(*args).tap {|o| o.save }
      end
      
      def create!(*args)
        new(*args).tap {|o| o.save! }
      end
      
      def inherited(subc) # :nodoc:
        # Make subclasses of each have their own root class/indexer
        subc.instance_eval do
          def root_class
            self
          end
        end
      end
    end
    
    private
    def create_or_update
      result = persisted? ? update : create
      result != false
    end
    
    def update
      # call the java property mixin's update method
      super(@_unsaved_props)
      @_unsaved_props.clear
      true
    end
    
    def create
      @_unsaved_props.clear
      @persisted = true
    end
  end
end
