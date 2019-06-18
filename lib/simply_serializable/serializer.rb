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
      except: nil,
      include_readable_instance_variables: true,
      method_prefix: :serialize,
      object:,
      only: nil
    )
      @object = object
      @id = id
      @attributes = attributes
      @include_readable_instance_variables = include_readable_instance_variables
      @except = except&.map(&:to_sym)
      @only = only&.map(&:to_sym)
      @method_prefix = method_prefix
      @local_cache = cache
      @local_cache[cache_key] = nil

      populate_attributes
    end

    def cache
      @cache ||= begin
        serialize
        @local_cache
      end
    end

    def id
      @id ||= cache_key
    end

    def nestable?
      return @nestable unless @nestable.nil?

      serialize
      @nestable
    end

    def nested
      @nested ||= begin
        deep_nest(serialize[:root])
      end
    end

    def serialize
      @serialize ||= begin
        @nestable = true
        ret = deep_serialize(object_value_hash)

        @local_cache[cache_key] = {
          id: cache_key,
          object: object.class.name,
          fingeprint: fingerprint,
          data: ret
        }

        {
          root: cache_key,
          objects: @local_cache
        }
      end
    end

    def to_s
      @to_s ||= serialize.to_s
    end

    private

    def cache_key
      @cache_key ||= cache_key_for(object)
    end

    def cache_key_for(obj)
      "#{obj.class.name}/#{fingerprint_for(obj)}"
    end

    def deep_nest(obj_id)
      raise Error::CircularDependencyError unless @nestable

      Hash[@local_cache[obj_id][:data].map do |k, v|
        v = deep_nest(v.dig(:id)) if v.is_a?(Hash) && v.dig(:object) == :reference
        [k, v]
      end]
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

    def fingerprint
      @fingerprint ||= fingerprint_for(object)
    end

    def fingerprint_for(obj)
      if obj.respond_to?(:fingerprint)
        obj.fingerprint
      else
        Fingerprintable::Fingerprinter.new(object: obj).fingerprint
      end
    end

    def instance_vars_with_readers
      instance_variables = Hash[object.instance_variables.map { |e| [e, 1] }]
      ret = object.class.instance_methods.select do |method|
        instance_variables.key?("@#{method}".to_sym)
      end
      ret.map(&:to_sym)
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

    def populate_attributes
      raise 'You cannot pass only and except values.  Please choose one.' if !only.nil? && !except.nil?

      @attributes |= instance_vars_with_readers if @include_readable_instance_variables

      @attributes = only unless only.nil?
      @attributes = attributes - except unless except.nil?
      attributes
    end

    def serialize_object(use_object)
      use_object_cache_key = cache_key_for(use_object)
      if @local_cache.key?(use_object_cache_key)
        @nestable = false
        return reference_to(use_object_cache_key)
      end
      serializer =  unless use_object.respond_to?(:serialize)
                      raise "#{use_object.class.name} does not respond to serialize.  Did you mean to include Serializable in this class?" unless @include_readable_instance_variables

                      Serializer.new(
                        cache: @local_cache,
                        object: use_object
                      )
                    else
                      use_object.serializer(cache: @local_cache)
                    end
      serializer
      @local_cache.merge!(serializer.cache)
      reference_to(use_object_cache_key)
    end

    def reference_to(key)
      {
        object: :reference,
        id: key
      }
    end
  end
end
