require 'spec_helper'

# frozen_string_literal: true

require 'spec_helper'

module SimplySerializable
  class MixinTestObject
    include Mixin

    serialize attributes: %i[foo],
              do_not_serialize_if_class_is: Date

    def foo
      :foo
    end
  end
end

RSpec.describe SimplySerializable::Mixin do
  let(:klass) { SimplySerializable::MixinTestObject }
  subject { klass.new }

  context '#serialize' do
    it { expect(subject).to respond_to(:serialize) }
  end

  context '#serializer' do
    it { expect(subject).to respond_to(:serializer) }
    it { expect(subject.serializer).to be_a(SimplySerializable::Serializer) }
  end

  context '#serializable_id' do
    it { expect(subject).to respond_to(:serializable_id) }
    it { expect(subject.serializable_id).to eq('SimplySerializable::MixinTestObject/d751713988987e9331980363e24189ce') }
  end

  context '.serialize' do
    # subject { described_class.serializable_config }

    it { expect(klass).to respond_to(:serialize) }
  end

  context '.serializable_config' do
    subject { klass.serializable_config }

    it { expect(klass).to respond_to(:serializable_config) }
    it { expect(subject[:attributes]).to eq(%i[foo]) }
    it { expect(subject[:do_not_serialize_if_class_is]).to eq(Date) }
  end
end
