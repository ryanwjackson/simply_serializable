require 'fingerprintable'

require "simply_serializable/version"
require "simply_serializable/serializer"
require "simply_serializable/mixin"

module SimplySerializable
  class Error < StandardError
    attr_reader :type

    def initialize(message, type:)
      @type = type
      super(message)
    end

    class CircularDependencyError < Error
      def initialize
        super(
          'Circular dependency detected',
          type: :circular_dependency
        )
      end
    end
  end
end
