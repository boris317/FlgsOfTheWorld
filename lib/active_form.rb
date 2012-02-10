module ActiveForm
  
  class ValidationError < StandardError
    attr_accessor :form
    def initialize(form)
      @form = form
    end
  end
  
  class Base
    include ActiveModel::Serializers::JSON
    include ActiveModel::Validations

    attr_accessor :attributes
            
    def initialize(attrs={})
      attributes = {}
      #symbolize all keys.
      attrs.each_pair {|k,v| attributes[k.to_sym] = v}
      if respond_to? :defaults_
        @attributes = Hash[
          *defaults_.zip([nil] * defaults_.count).flatten
        ].merge(attributes)
      else
        @attributes = attributes
      end
    end
    
    def self.form_attr_accessor(*attrs)
      # This is probably a terrible solution =p. Using the ``@attributes`` variable
      # as a container for our form's attributes leaves us in a bad state when the class
      # is initialized without any arguments. Here is an example:
      #
      #   class TestForm < ActiveForm::Base
      #     validates :foo, :bar, :presence => true
      #
      #   form = TestForm.new
      #   form.foo -> raises NoMethodError
      #
      # Defining ``form_attr_accessor`` lets us use a familiar interface to solve this problem. 
      # We can "save" the attribute symbols in a closure then retrieve them during object 
      # initialization, setting them to nil if they were not passed in.
      #
      #   class TestForm < ActiveForm::Base
      #     validates :foo, :bar, :presence => true
      #     form_attr_accessor :foo, :bar
      #
      #   form = TestForm.new
      #   form.foo -> nil
      #
      define_method("defaults_") do 
        (attrs ||= []).map {|a| a.to_sym}
      end
    end
    
    def read_attribute_for_serialization(key)
      @attributes[key]
    end

    def read_attribute_for_validation(key)
      @attributes[key]
    end

    def as_json(options={})
      # Turn ``include_root_in_json`` off
      super({ :root => false }.merge(options))
    end

    def method_missing(meth, *args, &block)
      if meth.to_s[-1] == "="
        @attributes[meth.to_s[0...-1].to_sym] = args[0]
      elsif meth == :to_key #to_key is responsible for returing the db primary key?
        nil
      elsif @attributes.has_key? meth
        @attributes[meth]
      else
        super
      end
    end
  end
  
  def validate(params, validator)
    obj = validator.new(params)
    if obj.invalid?
      exc = ValidationError.new(obj)
      # If a ``obj`` fails validation and ``validate`` was
      # pass a block call the block passing it the ``obj``.
      if block_given?
        yield obj 
      else
        raise exc
      end
    end
    return obj
  end
  
  module_function :validate
end