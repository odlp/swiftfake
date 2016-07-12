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
      functions: functions,
      imports: ['import Foundation', 'import UIKit']
    )
  }

  let(:presenter) { described_class.new(swift_class) }

  describe '#fake_class_signature' do
    subject { presenter.fake_class_signature }

    it 'includes the access, fake class name, and inheritance' do
      expect(subject).to eq('public class FakeSomeClass: SomeClass')
    end
  end

  describe '#import_statements' do
    subject { presenter.import_statements }

    it 'joins the imports from the class with newlines' do
      expect(subject).to eq("import Foundation\nimport UIKit")
    end

    it 'returns an empty string when there are no imports' do
      no_imports = Swiftfake::SwiftClass.new(
        name: 'SomeClass',
        access: 'public',
        functions: functions,
        imports: []
      )

      presenter = described_class.new(no_imports)

      expect(presenter.import_statements).to eq("")
      expect(presenter.import_statements.empty?).to eq(true)
    end
  end

  describe '#functions' do
    it 'passes the SwiftClass functions' do
      expect(presenter.functions).to eq(functions)
    end

    it 'extends the functions with the decorator' do
      func = presenter.functions.first
      decorator_methods = Swiftfake::FunctionDecorator.public_instance_methods
      expect(func.public_methods).to include(*decorator_methods)
    end
  end

  describe '#functions_with_args' do
    let(:functions) {[
      Swiftfake::SwiftFunction.new(
        full_name: 'internal func internalFunc() -> String',
        name: 'internalFunc',
        access: 'internal',
        arguments: [],
        return_value: 'String'
      ),
      Swiftfake::SwiftFunction.new(
        full_name: 'internal func internalFunc() -> String',
        name: 'internalFunc',
        access: 'internal',
        arguments: [Swiftfake::SwiftFunction::Argument.new('arg1', 'String')],
        return_value: 'String'
      )
    ]}

    subject { presenter.functions_with_args  }

    it 'selects functions with arguments' do
      expect(subject).to eq [functions.last]
    end
  end

  describe '#functions_with_return_value' do
    let(:functions) {[
      Swiftfake::SwiftFunction.new(
        full_name: 'internal func internalFunc()',
        name: 'internalFunc',
        access: 'internal',
        arguments: [],
        return_value: nil
      ),
      Swiftfake::SwiftFunction.new(
        full_name: 'internal func internalFunc() -> String',
        name: 'internalFunc',
        access: 'internal',
        arguments: [],
        return_value: 'String'
      )
    ]}

    subject { presenter.functions_with_return_value }

    it 'selects functions with arguments' do
      expect(subject).to eq [functions.last]
    end
  end

end
