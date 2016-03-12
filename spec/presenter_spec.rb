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
      expect(subject).to eq('public class FakeSomeClass: SomeClass')
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

  describe '#function_call_count' do
    subject { presenter.function_call_count(functions.first) }

    it 'appends "CallCount" to the function name' do
      expect(subject).to eq('internalFuncCallCount')
    end
  end

  describe '#function_call_declaration' do
    subject { presenter.function_call_count_declaration(function) }

    let(:function) {
      Swiftfake::SwiftFunction.new(
        full_name: 'internal func internalFunc()',
        name: 'internalFunc',
        access: 'internal',
        arguments: [],
        return_value: nil)
    }

    it 'set the initial call count to zero' do
      expect(subject).to eq('var internalFuncCallCount = 0')
    end

    context 'class method' do
      let(:function) {
        Swiftfake::SwiftFunction.new(
          full_name: 'internal class func internalFunc()',
          name: 'internalFunc',
          access: 'internal',
          arguments: [],
          return_value: nil)
      }

      it 'delcares a static var' do
        expect(subject).to eq('static var internalFuncCallCount = 0')
      end
    end
  end

  describe '#function_has_args' do
    subject { presenter.function_has_args?(function) }

    context 'no arguments' do
      let(:function) {
        Swiftfake::SwiftFunction.new(
          full_name: 'internal func internalFunc()',
          name: 'internalFunc',
          access: 'internal',
          arguments: [],
          return_value: nil)
      }

      it { is_expected.to be false }
    end

    context 'has arguments' do
      let(:function) {
        Swiftfake::SwiftFunction.new(
          full_name: 'internal func internalFunc()',
          name: 'internalFunc',
          access: 'internal',
          arguments: ['Some thing'],
          return_value: nil)
      }

      it { is_expected.to be true }
    end
  end

  describe '#function_args_store_name' do
    subject { presenter.function_args_store_name(functions.first) }

    it 'appends "ArgsForCall"' do
      expect(subject).to eq 'internalFuncArgsForCall'
    end
  end

  describe '#function_args_store_append' do
    subject { presenter.function_args_store_append(function) }

    let(:arg1) { Swiftfake::SwiftFunction::Argument.new('arg1', 'String') }

    context 'single argument' do
      let(:function) {
        Swiftfake::SwiftFunction.new(
          full_name: 'internal func internalFunc()',
          name: 'internalFunc',
          access: 'internal',
          arguments: [arg1],
          return_value: nil)
      }

      it 'appends the argument directly' do
        expect(subject).to eq 'internalFuncArgsForCall.append(arg1)'
      end
    end

    context 'multiple arguments' do
      let(:arg2) { Swiftfake::SwiftFunction::Argument.new('arg2', 'Int') }

      let(:function) {
        Swiftfake::SwiftFunction.new(
          full_name: 'internal func internalFunc()',
          name: 'internalFunc',
          access: 'internal',
          arguments: [arg1, arg2],
          return_value: nil)
      }

      it 'appends an argument tuple' do
        expect(subject).to eq 'internalFuncArgsForCall.append((arg1, arg2))'
      end
    end
  end

  describe '#function_args_store_delcaration' do
    subject { presenter.function_args_store_declaration(function) }

    let(:arg1) { Swiftfake::SwiftFunction::Argument.new('arg1', 'String') }

    context 'single argument' do
      let(:function) {
        Swiftfake::SwiftFunction.new(
          full_name: 'internal func internalFunc()',
          name: 'internalFunc',
          access: 'internal',
          arguments: [arg1],
          return_value: nil)
      }

      it 'declares an array of the argument type' do
        expect(subject).to eq 'var internalFuncArgsForCall = [String]()'
      end
    end

    context 'multiple arguments' do
      let(:arg2) { Swiftfake::SwiftFunction::Argument.new('arg2', 'Int') }

      let(:function) {
        Swiftfake::SwiftFunction.new(
          full_name: 'internal func internalFunc()',
          name: 'internalFunc',
          access: 'internal',
          arguments: [arg1, arg2],
          return_value: nil)
      }

      it 'declares an array of tuples with all the arguments' do
        expect(subject).to eq 'var internalFuncArgsForCall = [(arg1: String, arg2: Int)]()'
      end
    end

    context 'arguments for a class method call' do
      let(:function) {
        Swiftfake::SwiftFunction.new(
          full_name: 'internal class func internalFunc()',
          name: 'internalFunc',
          access: 'internal',
          arguments: [arg1],
          return_value: nil)
      }

      it 'declares an array of the argument type' do
        expect(subject).to eq 'static var internalFuncArgsForCall = [String]()'
      end
    end
  end

  describe '#function_returns?' do
    subject { presenter.function_returns?(function) }

    context 'has return value' do
      let(:function) {
        Swiftfake::SwiftFunction.new(
          full_name: 'internal func internalFunc() -> String',
          name: 'internalFunc',
          access: 'internal',
          arguments: [],
          return_value: 'String')
      }

      it { is_expected.to be true }
    end

    context 'has no return value' do
      let(:function) {
        Swiftfake::SwiftFunction.new(
          full_name: 'internal func internalFunc()',
          name: 'internalFunc',
          access: 'internal',
          arguments: [],
          return_value: nil)
      }

      it { is_expected.to be false }
    end
  end

  describe '#function_return_value' do
    subject { presenter.function_return_value(function) }

    let(:function) {
      Swiftfake::SwiftFunction.new(
        full_name: 'internal func internalFunc() -> String',
        name: 'internalFunc',
        access: 'internal',
        arguments: [],
        return_value: 'String')
    }

    it 'prepends "return" and instantiates the object' do
      expect(subject).to eq 'return String()'
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

end
