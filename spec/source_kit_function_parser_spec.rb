require 'spec_helper'
require 'swiftfake/source_kit_parser'

describe Swiftfake::SourceKitParser::FunctionParser do

  def parse_line(line)
    described_class.new.parse(line)
  end

  describe '#parse' do
    describe 'function attributes' do
      let(:line) { '  internal func internalFunc()'  }
      subject { described_class.new.parse(line) }

      it 'has the full name, stripped of whitespace' do
        expect(subject.full_name).to eq 'internal func internalFunc()'
      end

      it 'has a name' do
        expect(subject.name).to eq 'internalFunc'
      end

      it 'has an access level' do
        expect(subject.access).to eq 'internal'
      end

      context 'access level not defined' do
        let(:line) { 'func internalFunc()'  }

        it 'defaults to internal' do
          expect(subject.access).to eq 'internal'
        end
      end
    end

    describe 'function arguments' do
      def parse_first_arg(line)
        described_class.new.parse(line).arguments.first
      end

      it 'parses no arguments' do
        line = 'internal func internalFunc()'
        args = described_class.new.parse(line).arguments
        expect(args).to eq([])
      end

      it 'parses String attributes' do
        arg = parse_first_arg('internal func withString(value: String)')
        expect(arg.name).to eq('value')
        expect(arg.type).to eq('String')
      end

      it 'parses Int attributes' do
        arg = parse_first_arg('internal func withInt(value: Int)')
        expect(arg.name).to eq('value')
        expect(arg.type).to eq('Int')
      end

      it 'parses Array attributes' do
        arg = parse_first_arg('internal func withArray(value: [String])')
        expect(arg.name).to eq('value')
        expect(arg.type).to eq('[String]')
      end

      it 'parses Dictionary attributes' do
        arg = parse_first_arg('internal func withDictionary(value: [String : AnyObject])')
        expect(arg.name).to eq('value')
        expect(arg.type).to eq('[String : AnyObject]')
      end

      it 'parses Object attributes' do
        arg = parse_first_arg('internal func withObject(value: SomeObject)')
        expect(arg.name).to eq('value')
        expect(arg.type).to eq('SomeObject')
      end
    end

    describe 'function return value' do
      def parse_return(line)
        described_class.new.parse(line).return_value
      end

      it 'returns nil if the function has no return value' do
        value = parse_return('internal func myFunc(arg1: String)')
        expect(value).to be_nil
      end

      it 'parses single return values' do
        value = parse_return('internal func myFunc(arg1: String) -> String')
        expect(value).to eq('String')
      end

      it 'parses optional-type return values' do
        value = parse_return('internal func myFuncOptionalReturn(arg1: String) -> String?')
        expect(value).to eq('String?')
      end

      it 'parses tuple return values' do
        value = parse_return('internal func myFuncReturningTuple() -> (val1: String, val2: String)')
        expect(value).to eq('(val1: String, val2: String)')
      end
    end

    describe 'filtering of functions' do
      it 'only returns internal / public functions which can be overriden' do
        wanted_funcs = [
          'internal class func classInternalFunc()',
          'public class func classPublicFunc()',
          'internal func internalFunc()',
          'public func publicFunc()'
        ]
        unwanted_funcs = [
          'private final class func staticPrivateFunc()',
          'internal final class func staticInternalFunc()',
          'public final class func staticPublicFunc()',
          'private class func classPrivateFunc()',
          'final private func finalPrivateFunc()',
          'final internal func finalInternalFunc()',
          'final public func finalPublicFunc()',
          'private func privateFunc()'
        ]

        parsedFunctions = (unwanted_funcs + wanted_funcs)
          .map{ |f| described_class.new.parse(f) }
          .compact

        expect(parsedFunctions.count).to eq(wanted_funcs.count)
      end
    end
  end
end
