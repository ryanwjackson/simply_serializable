# frozen_string_literal: true

module SimplySerializable
  module Mixin
    module ClassMethods
      def inherited(subclass)
        subclass.serializes()
        super(subclass)
      end

      def serialize(attributes: [], except: [], only: [])
        serializable_config[:attributes] = serializable_config[:attributes] |= attributes
        serializable_config[:except] = serializable_config[:except] |= except
        serializable_config[:only] = serializable_config[:only] |= only
      end

      def serializable_config
        @serializable_config ||= {
          attributes: [],
          except: [],
          only: []
        }
      end
    end

    def self.included(base)
      base.include(Fingerprintable::Mixin)
      base.extend(ClassMethods)
    end

    def serialize(cache: {})
      serializer(cache: cache).serialize
    end

    def serializer(cache: {})
      Serializer.new(
        **self.class.serializable_config.merge(
          cache: cache,
          object: self
        )
      )
    end

    def serializable_id
      "#{serializable_type}/#{fingerprint}"
    end

    def serializable_type
      self.class.name
    end
  end
end
