# frozen_string_literal: true

require 'spec_helper'

module SimplySerializable
  class SerializableTestObject
    include SimplySerializable::Mixin

    attr_reader :cycle_attr, :readable_instance_attr

    serialize attributes: [
      :cycle_attr,
      :false_attr,
      :integer_attr,
      :list_attr,
      :method_detection,
      :nil_attr,
      :other_obj,
      :string_attr,
      :symbol_attr,
      :true_attr,
      :with_self,
      'float_attr'
    ]

    serialize attributes: %i[additive]

    def initialize(cycle_attr: nil)
      @cycle_attr = cycle_attr || self.class.new(cycle_attr: self)
      @readable_instance_attr = :readable_instance_attr_val
    end

    def additive
      :additive_val
    end

    def false_attr
      false
    end

    def float_attr
      1.23
    end

    def integer_attr
      987
    end

    def list_attr
      [
        SerializableExceptTestObject.new,
        :b
      ]
    end

    def nil_attr
      nil
    end

    def other_obj
      SerializableExceptTestObject.new
    end

    def serialize_method_detection
      :serialize_method_detection_value
    end

    def string_attr
      'asdf'
    end

    def symbol_attr
      :qwerty
    end

    def true_attr
      true
    end

    def with_self
      self
    end
  end

  class SerializableCycleTestObject
    include SimplySerializable::Mixin

    attr_reader :loop

    def initialize(loop:)
      @loop = loop
    end
  end

  class SerializableExceptTestObject
    include SimplySerializable::Mixin

    serialize attributes: %i[nested],
              except: %i[except_this_one]

    def except_this_one
      :not_included
    end

    def nested
      SerializableOnlyTestObject.new
    end
  end

  class SerializableOnlyTestObject
    include SimplySerializable::Mixin

    attr_reader :not_included

    serialize attributes: %i[also_not_included],
              only: %i[end_of_the_line]

    def end_of_the_line
      :end_of_the_line_value
    end
  end
end

RSpec.describe SimplySerializable::Serializer do
  subject { SimplySerializable::SerializableTestObject.new.serialize }

  it do
    h = {
      root: 'SimplySerializable::SerializableTestObject/daaf6256673afd34f86391a8a7684a49',
      objects: {
        'SimplySerializable::SerializableTestObject/daaf6256673afd34f86391a8a7684a49' => {
          additive: :additive_val,
          :cycle_attr => 'SimplySerializable::SerializableTestObject/daaf6256673afd34f86391a8a7684a49',
          :false_attr => false,
          :integer_attr => 987,
          :list_attr => [
            'SimplySerializable::SerializableExceptTestObject/d751713988987e9331980363e24189ce',
            :b
          ],
          :method_detection => :serialize_method_detection_value,
          :nil_attr => nil,
          :other_obj => 'SimplySerializable::SerializableExceptTestObject/d751713988987e9331980363e24189ce',
          :string_attr => 'asdf',
          :symbol_attr => :qwerty,
          :true_attr => true,
          :with_self => 'SimplySerializable::SerializableTestObject/daaf6256673afd34f86391a8a7684a49',
          'float_attr' => 1.23,
          :readable_instance_attr => :readable_instance_attr_val
        },
        'SimplySerializable::SerializableExceptTestObject/d751713988987e9331980363e24189ce' => {
          nested: 'SimplySerializable::SerializableOnlyTestObject/d751713988987e9331980363e24189ce'
        },
        'SimplySerializable::SerializableOnlyTestObject/d751713988987e9331980363e24189ce' => {}
      }
    }
    expect(subject).to eq(h)
  end
end
