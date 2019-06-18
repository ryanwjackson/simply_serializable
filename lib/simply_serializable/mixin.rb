# frozen_string_literal: true

module SimplySerializable
  module Mixin
    module ClassMethods
      def inherited(subclass)
        subclass.serialize(**serializable_config)
        super(subclass)
      end

      def serialize(attributes: [], except: nil, only: nil)
        serializable_config[:attributes] = serializable_config[:attributes] |= attributes
        unless except.nil?
          serializable_config[:except] ||= []
          serializable_config[:except] = serializable_config[:except] |= except
        end

        unless only.nil?
          serializable_config[:only] ||= []
          serializable_config[:only] = serializable_config[:only] |= only
        end
      end

      def serializable_config
        @serializable_config ||= {
          attributes: [],
          except: nil,
          only: nil
        }
      end
    end

    def self.included(base)
      base.include(Fingerprintable::Mixin)
      base.extend(ClassMethods)
    end

    def serialize(cache: {}, **options)
      serializer(cache: cache, **options).serialize
    end

    def serializer(cache: {}, **options)
      Serializer.new(
        **self.class.serializable_config.merge(
          options
        ).merge(
          cache: cache,
          object: self
        )
      )
    end

    def serializable_id
      serializer.id
    end
  end
end
