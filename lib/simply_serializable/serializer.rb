# frozen_string_literal: true

module SimplySerializable
  class Serializer
    attr_reader :attributes,
                :except,
                :object,
                :only

    def initialize(
      attributes: [],
      cache: {},
      except: [],
      include_readable_instance_variables: true,
      method_prefix: :serialize,
      object:,
      only: []
    )
      @object = object
      @attributes = attributes
      @include_readable_instance_variables = include_readable_instance_variables
      @except = except.map(&:to_sym)
      @only = only.map(&:to_sym)
      @method_prefix = method_prefix
      @cache = cache
      @cache[cache_key] = nil
      @serialized = false

      populate_attributes
    end

    def cache
      serialize unless @serialized
      @cache
    end

    def deep_serialize(obj)
      case obj
      when FalseClass, Float, nil, Integer, String, Symbol, TrueClass
        obj
      when Array
        obj.map { |v| deep_serialize(v) }
      when Hash
        Hash[obj.map { |k, v| [deep_serialize(k), deep_serialize(v)] }]
      when Module
        obj.name
      else
        serialize_object(obj)
      end
    end

    def serialize
      @serialize ||= begin
        @serialized = true
        ret = deep_serialize(object_value_hash)

        cache[cache_key] = ret
        {
          root: cache_key,
          objects: cache
        }
      end
    end

    def to_s
      @to_s ||= serialize.to_s
    end

    private

    def instance_vars_with_readers
      instance_variables = Hash[object.instance_variables.map { |e| [e, 1] }]
      ret = object.class.instance_methods.select do |method|
        instance_variables.key?("@#{method}".to_sym)
      end
      ret.map(&:to_sym)
    end

    def serialize_object(use_object)
      use_object_cache_key = cache_key(use_object)
      return use_object_cache_key if cache.key?(use_object_cache_key)
      raise "#{use_object.class.name} does not respond to serialize.  Did you mean to include Serializable in this class?" unless use_object.respond_to?(:serialize)

      serializer = use_object.serializer(cache: cache)
      cache.merge!(serializer.cache)
      use_object_cache_key
    end

    def cache_key(obj = object)
      obj.serializable_id
    end

    def populate_attributes
      raise 'You cannot pass only and except values.  Please choose one.' if only.any? && except.any?

      @attributes |= instance_vars_with_readers if @include_readable_instance_variables

      @attributes = attributes & only if only.any?
      @attributes = attributes - except if except.any?
      attributes
    end

    def method_for_attribute(attr)
      if object.class.instance_methods.include?("#{@method_prefix}_#{attr}".to_sym)
        "#{@method_prefix}_#{attr}"
      else
        attr
      end
    end

    def object_value_hash
      Hash[attributes.map do |attr|
        [attr, object.send(method_for_attribute(attr))]
      end]
    end
  end
end
