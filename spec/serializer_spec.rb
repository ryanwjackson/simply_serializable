# frozen_string_literal: true

require 'spec_helper'

module SimplySerializable
  class SerializableTestObject
    attr_accessor :child, :foo

    def initialize(child: nil, foo: nil)
      @child = child
      @foo = foo
    end

    def bar
      :bar_val
    end
  end
end

RSpec.describe SimplySerializable::Serializer do
  let(:klass) { SimplySerializable::SerializableTestObject }

  let(:params) { {} }
  let(:object) { klass.new }

  let(:serializer) { s(object, **params) }

  def s(obj, **keywords)
    described_class.new(object: obj, **keywords)
  end

  describe '.id' do
    subject { serializer.id }

    it { expect(subject).to eq('SimplySerializable::SerializableTestObject/b69a732655038977df8e6042cbeff356') }
  end

  describe '.nested' do
    subject { serializer.nested }

    it do
      h = { child: nil, foo: nil }
      expect(subject).to eq(h)
    end

    it 'detects cycles' do
      object.child = object
      expect(serializer).not_to be_nestable
      expect { subject }.to raise_error(SimplySerializable::Error::CircularDependencyError)
    end

    it 'nests' do
      object.foo = :obj1
      object.child = klass.new(
        child: klass.new(
          foo: :obj3
        ),
        foo: :obj2
      )
      h = {
        child: {
          child: {
            child: nil,
            foo: :obj3
          },
          foo: :obj2
        },
        foo: :obj1
      }
      expect(subject).to eq(h)
    end
  end

  describe '.serialize' do
    subject { serializer.serialize }

    it do
      h = {
        root: 'SimplySerializable::SerializableTestObject/b69a732655038977df8e6042cbeff356',
        objects: {
          'SimplySerializable::SerializableTestObject/b69a732655038977df8e6042cbeff356' => {
            id: 'SimplySerializable::SerializableTestObject/b69a732655038977df8e6042cbeff356',
            object: 'SimplySerializable::SerializableTestObject',
            fingeprint: 'b69a732655038977df8e6042cbeff356',
            data: {
              child: nil,
              foo: nil
            }
          }
        }
      }
      expect(subject).to eq(h)
    end

    it 'handles nesting' do
      object.foo = :obj1
      object.child = klass.new(
        child: klass.new(
          foo: :obj3
        ),
        foo: :obj2
      )

      h = {
        root: 'SimplySerializable::SerializableTestObject/a3a7d5ca3e07c4455fcb450357503571',
        objects: {
          'SimplySerializable::SerializableTestObject/a3a7d5ca3e07c4455fcb450357503571' => {
            id: 'SimplySerializable::SerializableTestObject/a3a7d5ca3e07c4455fcb450357503571',
            object: 'SimplySerializable::SerializableTestObject',
            fingeprint: 'a3a7d5ca3e07c4455fcb450357503571',
            data: {
              child: {
                object: :reference,
                id: 'SimplySerializable::SerializableTestObject/b401c9c0eef359d48436bcf5b24439d7'
              },
              foo: :obj1
            }
          },
          'SimplySerializable::SerializableTestObject/b401c9c0eef359d48436bcf5b24439d7' => {
            id: 'SimplySerializable::SerializableTestObject/b401c9c0eef359d48436bcf5b24439d7',
            object: 'SimplySerializable::SerializableTestObject',
            fingeprint: 'b401c9c0eef359d48436bcf5b24439d7',
            data: {
              child: {
                object: :reference,
                id: 'SimplySerializable::SerializableTestObject/d50ff3c9f6b0877c3f6ac9c7d7e5bdc1'
              },
              foo: :obj2
            }
          },
          'SimplySerializable::SerializableTestObject/d50ff3c9f6b0877c3f6ac9c7d7e5bdc1' => {
            id: 'SimplySerializable::SerializableTestObject/d50ff3c9f6b0877c3f6ac9c7d7e5bdc1',
            object: 'SimplySerializable::SerializableTestObject',
            fingeprint: 'd50ff3c9f6b0877c3f6ac9c7d7e5bdc1',
            data: {
              child: nil,
              foo: :obj3
            }
          }
        }
      }
      expect(subject).to eq(h)
    end

    it 'handles cycles' do
      object.child = object

      h = {
        root: 'SimplySerializable::SerializableTestObject/18e15a599b65120909ea046e560bd68f',
        objects: {
          'SimplySerializable::SerializableTestObject/18e15a599b65120909ea046e560bd68f' => {
            id: 'SimplySerializable::SerializableTestObject/18e15a599b65120909ea046e560bd68f',
            object: 'SimplySerializable::SerializableTestObject',
            fingeprint: '18e15a599b65120909ea046e560bd68f',
            data: {
              child: {
                object: :reference,
                id: 'SimplySerializable::SerializableTestObject/18e15a599b65120909ea046e560bd68f'
              },
              foo: nil
            }
          }
        }
      }
      expect(subject).to eq(h)
    end
  end

  context 'value types' do
    def val(use_val)
      serializer = described_class.new(object: klass.new(foo: use_val), **params)
      serializer.serialize[:objects][serializer.id][:data][:foo]
    end

    it { expect(val(nil)).to be_nil }

    it { expect(val(false)).to be_falsey }
    it { expect(val(true)).to be_truthy }

    it { expect(val(123)).to eq(123) }
    it { expect(val(1.2)).to eq(1.2) }

    it { expect(val('asdf')).to eq('asdf') }
    it { expect(val(:asdf)).to eq(:asdf) }

    it { expect(val([])).to eq([]) }
    it { expect(val({})).to eq({}) }

    it { expect(val(SimplySerializable)).to eq('SimplySerializable') }
  end
end
