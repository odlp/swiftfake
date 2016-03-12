require 'spec_helper'
require 'swiftfake/presenter'
require 'swiftfake/swift_class'
require 'swiftfake/swift_function'

describe Swiftfake::Presenter do

  let(:functions) {[
    Swiftfake::SwiftFunction.new(
      full_name: 'internal func internalFunc()',
      name: 'internalFunc',
      access: 'internal',
      arguments: [],
      return_value: nil
    )
  ]}

  let(:swift_class) {
    Swiftfake::SwiftClass.new(
      name: 'SomeClass',
      access: 'public',
      functions: functions
    )
  }

  let(:presenter) { described_class.new(swift_class) }

  describe '#fake_class_signature' do
    subject { presenter.fake_class_signature }

    it 'includes the access, fake class name, and inheritance' do
      expect(subject).to eq('public FakeSomeClass: SomeClass')
    end
  end

  describe '#functions' do
    it 'passes the SwiftClass functions' do
      expect(presenter.functions).to eq(functions)
    end
  end

  describe '#function_signature' do
    subject { presenter.function_signature(functions.first) }

    it 'prepends "override" to the original signature' do
      expect(subject).to eq('override internal func internalFunc()')
    end
  end

end
