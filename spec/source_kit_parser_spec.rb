require 'spec_helper'
require 'swiftfake/source_kit_parser'

describe Swiftfake::SourceKitParser do

  let(:source_file)     { File.read('spec/examples/BasicClass.swift') }
  let(:raw_structure_json)  { File.read('spec/examples/BasicClass.json') }

  describe '#parse' do

    subject { described_class.new.parse(source_file, raw_structure_json) }

    it 'parses the class attributes' do
      expect(subject.name).to eq('BasicClass')
      expect(subject.access).to eq('internal')
    end

    it 'parses the import statements from the source' do
      expect(subject.imports)
        .to contain_exactly('import Foundation', 'import UIKit')
    end

    it 'parses the functions' do
      expect(subject.functions.count).to eq(1)
      expect(subject.functions.first.full_name)
        .to eq "func sayHi()"
    end

    context 'functions with return values' do
      let(:source_file)     { File.read('spec/examples/ReturnValueFuncs.swift') }
      let(:raw_structure_json)  { File.read('spec/examples/ReturnValueFuncs.json') }

      before(:each) {
        expect(subject.functions.count).to eq(3)
      }

      it 'handles returning a basic types' do
        expect(subject.functions[0].return_value).to eq('String')
      end

      it 'handles returning a optionals' do
        expect(subject.functions[1].return_value).to eq('String?')
      end

      it 'handles tuples' do
        expect(subject.functions[2].return_value).to eq('(val1: String, val2: String)')
      end
    end

    context 'functions with a single argument' do
      let(:source_file)     { File.read('spec/examples/SingleArgFuncs.swift') }
      let(:raw_structure_json)  { File.read('spec/examples/SingleArgFuncs.json') }

      before(:each) {
        expect(subject.functions.count).to eq(5)
      }

      it 'handles a String' do
        arg = subject.functions[0].arguments[0]

        expect(arg.name).to eq('value')
        expect(arg.type).to eq('String')
      end

      it 'handles an Int' do
        arg = subject.functions[1].arguments[0]

        expect(arg.type).to eq('Int')
      end

      it 'handles an Array of String' do
        arg = subject.functions[2].arguments[0]

        expect(arg.type).to eq('[String]')
      end

      it 'handles an Dictionary' do
        arg = subject.functions[3].arguments[0]

        expect(arg.type).to eq('[String: AnyObject]')
      end

      it 'handles an Object' do
        arg = subject.functions[4].arguments[0]

        expect(arg.type).to eq('SomeObject')
      end
    end

    describe 'filtering function types' do
      let(:source_file)     { File.read('spec/examples/AllFuncsClass.swift') }
      let(:raw_structure_json)  { File.read('spec/examples/AllFuncsClass.json') }

      it 'ignores private / final functions' do
        access_levels = subject.functions.map {|f| f.access }
        full_names = subject.functions.map {|f| f.full_name }

        expect(access_levels).to_not include('private')
        expect(full_names.join(', ')).to_not include('final')
      end
    end

  end
end
