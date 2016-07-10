require 'spec_helper'
require 'swiftfake/source_kit_parser'

describe Swiftfake::SourceKitParser do

  let(:source_file)     { File.read('spec/examples/BasicClass.swift') }
  let(:raw_structure_json)  { File.read('spec/examples/BasicClass.json') }

  describe '#parse' do
    it 'parses the class attributes' do
      klass = described_class.new.parse(source_file, raw_structure_json)

      expect(klass.name).to eq('BasicClass')
      expect(klass.access).to eq('internal')
    end

    it 'parses the functions' do
      klass = described_class.new.parse(source_file, raw_structure_json)

      expect(klass.functions.count).to eq(1)
      expect(klass.functions.first.full_name)
        .to eq "func sayHi()"
    end
  end
end
