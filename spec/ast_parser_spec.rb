require 'spec_helper'
require 'swiftfake/ast_parser'

describe Swiftfake::AstParser do

  let(:raw_ast) { File.read('spec/examples/BasicClass.ast') }

  describe '#parse' do
    it 'parses the class attributes' do
      klass = described_class.new.parse(raw_ast)

      expect(klass.name).to eq('BasicClass')
      expect(klass.access).to eq('internal')
    end

    it 'parses the functions' do
      klass = described_class.new.parse(raw_ast)

      expect(klass.functions.count).to eq(1)
      expect(klass.functions.first.full_name)
        .to eq "internal func sayHi()"
    end
  end
end
