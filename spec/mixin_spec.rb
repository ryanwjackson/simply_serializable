require 'spec_helper'

module SimplySerializable
  class MixinTestObject
    include SimplySerializable::Mixin

    attr_accessor

    fingerprint :baz,
                ignore: :bar

    fingerprint :asdf

    def initialize(foo = nil)
      self.foo = foo
    end
  end
end

RSpec.describe Fingerprintable::Mixin do
end
