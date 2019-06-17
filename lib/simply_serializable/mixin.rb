# frozen_string_literal: true

module SimplySerializable
  module Mixin
    module ClassMethods
      def inherited(subclass)
        subclass.serializes()
        super(subclass)
      end

      def serialize(**config)
        @serializable_config = config
      end

      def serializable_config
        @serializable_config ||= {}
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
        self.class.serializable_config.merge(
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
