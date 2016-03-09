require 'spec_helper'
require 'swiftfake/ast_parser'

describe Swiftfake::AstParser::FunctionsParser do

  def parse_line(line)
    described_class.new([line]).parse.first
  end

  describe '#parse' do
    describe 'function attributes' do
      let(:line) { '  internal func internalFunc()'  }
      subject { described_class.new([line]).parse.first }

      it 'has the full name, stripped of whitespace' do
        expect(subject.full_name).to eq 'internal func internalFunc()'
      end

      it 'has a name' do
        expect(subject.name).to eq 'internalFunc'
      end

      it 'has an access level' do
        expect(subject.access).to eq 'internal'
      end
    end

    describe 'function arguments' do
      def parse_first_arg(line)
        described_class.new([line]).parse.first.arguments.first
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

        parser = described_class.new(unwanted_funcs + wanted_funcs)
        expect(parser.parse.count).to eq(wanted_funcs.count)
      end
    end
  end
end
