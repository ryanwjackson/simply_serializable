# frozen_string_literal: true

module SimplySerializable
  module Mixin
    module ClassMethods
      def inherited(subclass)
        subclass.simply_serialize(**simply_serializable_config)
        super(subclass)
      end

      def simply_serialize(attributes: [], except: nil, only: nil, **keywords)
        simply_serializable_config[:attributes] = simply_serializable_config[:attributes] |= attributes

        unless except.nil?
          simply_serializable_config[:except] ||= []
          simply_serializable_config[:except] = simply_serializable_config[:except] |= except
        end

        unless only.nil?
          simply_serializable_config[:only] ||= []
          simply_serializable_config[:only] = simply_serializable_config[:only] |= only
        end

        simply_serializable_config.merge!(keywords)
      end

      def simply_serializable_config
        @simply_serializable_config ||= {
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

    def simply_serialize(cache: {}, **options)
      simply_serializer(cache: cache, **options).serialize
    end

    def simply_serializer(cache: {}, **options)
      Serializer.new(
        **self.class.simply_serializable_config.merge(
          options
        ).merge(
          cache: cache,
          object: self
        )
      )
    end

    def simply_serializable_id
      simply_serializer.id
    end
  end
end
