require 'spec_helper'

# frozen_string_literal: true

require 'spec_helper'

module SimplySerializable
  class MixinTestObject
    include Mixin

    simply_serialize attributes: %i[foo],
              do_not_serialize_if_class_is: Date

    def foo
      :foo
    end
  end
end

RSpec.describe SimplySerializable::Mixin do
  let(:klass) { SimplySerializable::MixinTestObject }
  subject { klass.new }

  context '#simply_serialize' do
    it { expect(subject).to respond_to(:simply_serialize) }
  end

  context '#simply_serializer' do
    it { expect(subject).to respond_to(:simply_serializer) }
    it { expect(subject.simply_serializer).to be_a(SimplySerializable::Serializer) }
  end

  context '#simply_serializable_id' do
    it { expect(subject).to respond_to(:simply_serializable_id) }
    it { expect(subject.simply_serializable_id).to eq('SimplySerializable::MixinTestObject/d751713988987e9331980363e24189ce') }
  end

  context '.simply_serialize' do
    # subject { described_class.serializable_config }

    it { expect(klass).to respond_to(:simply_serialize) }
  end

  context '.serializable_config' do
    subject { klass.simply_serializable_config }

    it { expect(klass).to respond_to(:simply_serializable_config) }
    it { expect(subject[:attributes]).to eq(%i[foo]) }
    it { expect(subject[:do_not_serialize_if_class_is]).to eq(Date) }
  end
end
