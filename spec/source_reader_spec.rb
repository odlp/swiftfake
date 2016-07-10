require 'spec_helper'
require 'swiftfake/source_reader'
require 'json'

describe Swiftfake::SourceReader do
  describe '#read_file' do

    let(:expected_source) { File.read('spec/examples/BasicClass.swift') }
    let(:expected_structure_json) { File.read('spec/examples/BasicClass.json') }

    it 'returns the source code and structure JSON from the source file' do
      source, structure_json = subject.read_file('spec/examples/BasicClass.swift')

      expect(source).to eq(expected_source)

      expect(structure_json).to eq(expected_structure_json)

      parsed_json = JSON.parse(structure_json)
      expect(parsed_json["key.substructure"][0]["key.name"]).to eq("BasicClass")
    end
  end
end
