require 'spec_helper'
require 'swiftfake/function_decorator'
require 'swiftfake/swift_function'

describe Swiftfake::FunctionDecorator do

  def create_function(full_name: 'internal func internalFunc()', name: 'internalFunc', access: 'internal', arguments: [], return_value: nil)
    Swiftfake::SwiftFunction.new(
      full_name: full_name,
      name: name,
      access: access,
      arguments: arguments,
      return_value: return_value
    )
  end

  let(:decorated) { function.extend(described_class) }

  describe '#signature' do
    let(:function) { create_function(full_name: 'internal func internalFunc()') }
    subject { decorated.signature }

    it 'prepends "override" to the original signature' do
      expect(subject).to eq('override internal func internalFunc()')
    end
  end

  describe '#call_count' do
    let(:function) { create_function(name: 'internalFunc') }
    subject { decorated.call_count }

    it 'appends "CallCount" to the function name' do
      expect(subject).to eq('internalFuncCallCount')
    end
  end

  describe '#call_count_declaration' do
    let(:function) { create_function(name: 'internalFunc') }
    subject { decorated.call_count_declaration }

    it 'set the initial call count to zero' do
      expect(subject).to eq('var internalFuncCallCount = 0')
    end

    context 'class method' do
      let(:function) {
        create_function(
          full_name: 'internal class func internalFunc()',
          name: 'internalFunc'
        )
      }

      it 'delcares a static var' do
        expect(subject).to eq('static var internalFuncCallCount = 0')
      end
    end
  end

  describe '#has_args?' do
    subject { decorated.has_args? }

    context 'no arguments' do
      let(:function) { create_function(arguments: []) }
      it { is_expected.to be false }
    end

    context 'has arguments' do
      let(:function) { create_function(arguments: ['Some thing']) }
      it { is_expected.to be true }
    end
  end

  describe '#args_store_append' do
    subject { decorated.args_store_append }

    let(:arg1) { Swiftfake::SwiftFunction::Argument.new('arg1', 'String') }

    context 'single argument' do
      let(:function) { create_function(arguments: [arg1]) }

      it 'appends the argument directly' do
        expect(subject).to eq 'internalFuncArgsForCall.append(arg1)'
      end
    end

    context 'multiple arguments' do
      let(:arg2) { Swiftfake::SwiftFunction::Argument.new('arg2', 'Int') }
      let(:function) { create_function(arguments: [arg1, arg2]) }

      it 'appends an argument tuple' do
        expect(subject).to eq 'internalFuncArgsForCall.append((arg1, arg2))'
      end
    end
  end

  describe '#args_store_declaration' do
    subject { decorated.args_store_declaration }

    let(:arg1) { Swiftfake::SwiftFunction::Argument.new('arg1', 'String') }

    context 'single argument' do
      let(:function) { create_function(arguments: [arg1]) }

      it 'declares an array of the argument type' do
        expect(subject).to eq 'var internalFuncArgsForCall = [String]()'
      end
    end

    context 'multiple arguments' do
      let(:arg2) { Swiftfake::SwiftFunction::Argument.new('arg2', 'Int') }
      let(:function) { create_function(arguments: [arg1, arg2]) }

      it 'declares an array of tuples with all the arguments' do
        expect(subject).to eq 'var internalFuncArgsForCall = [(arg1: String, arg2: Int)]()'
      end
    end

    context 'arguments for a class method call' do
      let(:function) { create_function(
        full_name: 'internal class func internalFunc()',
        arguments: [arg1])
      }

      it 'declares an array of the argument type' do
        expect(subject).to eq 'static var internalFuncArgsForCall = [String]()'
      end
    end
  end

  describe '#returns?' do
    subject { decorated.returns? }

    context 'has return value' do
      let(:function) { create_function(return_value: 'String') }
      it { is_expected.to be true }
    end

    context 'has no return value' do
      let(:function) { create_function(return_value: nil) }
      it { is_expected.to be false }
    end
  end

  describe '#return_value_declaration' do
    subject { decorated.return_value_declaration }

    let(:function) { create_function(
      name: 'internalFunc',
      return_value: 'String')
    }

    it 'returns the xReturnValue property' do
      expect(subject).to eq 'return internalFuncReturnValue'
    end
  end

  describe '#return_value_store_declaration' do
    subject { decorated.return_value_store_declaration }

    let(:function) { create_function(
      name: 'internalFunc',
      return_value: 'String')
    }

    it 'declares an variable with an freshly initialised return value' do
      expect(subject).to eq 'var internalFuncReturnValue = String()'
    end

    context 'return value is a named tuple' do
      let(:function) { create_function(
        name: 'internalFunc',
        return_value: '(val1: String, val2: String)')
      }

      it 'correctly instantiates the tuple values' do
        expect(subject).to eq 'var internalFuncReturnValue = (val1: String(), val2: String())'
      end
    end

    context 'return value is a plain tuple' do
      let(:function) { create_function(
        name: 'internalFunc',
        return_value: '(String, String)')
      }

      it 'correctly instantiates the tuple values' do
        expect(subject).to eq 'var internalFuncReturnValue = (String(), String())'
      end
    end

    context 'return value for a class method call' do
      let(:function) { create_function(
        full_name: 'internal class func internalFunc() -> String',
        return_value: 'String')
      }

      it 'declares a static variable with an freshly initialised return value' do
        expect(subject).to eq 'static var internalFuncReturnValue = String()'
      end
    end
  end
end
