module ActiveForm
  
  class ValidationError < StandardError
    attr_accessor :errors
    def initialize(errors)
      @errors = errors
    end
  end
  
  class Base
    include ActiveModel::Serializers::JSON
    include ActiveModel::Validations

    attr_accessor :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def read_attribute_for_serialization(key)
      @attributes[key]
    end

    def read_attribute_for_validation(key)
      @attributes[key]
    end

    def as_json(options)
      #turn include_root_in_json off
      options[:root] = false
      super(options)
    end

    def method_missing(meth, *args, &block)
      if meth.to_s[-1] == "="
        @attributes[meth.to_s[0...-1].to_sym] = args[0]
      elsif @attributes.has_key? meth
        @attributes[meth]
      else
        super
      end
    end
  end
  
  def validate(params, validator)
    obj = validator.new(params)
    if obj.invalid? then raise ValidationError.new(obj.errors) end    
    return obj
  end
  
  module_function :validate
end