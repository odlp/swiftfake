require 'spec_helper'
require 'swiftfake'

describe Swiftfake::Runner do

  describe '#run' do

    let(:source_file) { 'The source file contents' }
    let(:structure_json) { '{}' }

    let(:swift_class) { instance_double(Swiftfake::SwiftClass) }
    let(:source_reader) { instance_double(Swiftfake::SourceReader, read_file: [source_file, structure_json]) }

    let(:parser_klass) { class_double(Swiftfake::SourceKitParser, new: parser) }
    let(:parser) { instance_double(Swiftfake::SourceKitParser, parse: swift_class) }
    let(:presenter) { instance_double(Swiftfake::Presenter, get_binding: "binding") }
    let(:presenter_klass) { class_double(Swiftfake::Presenter, new: presenter) }
    let(:renderer) { instance_double(Swiftfake::Renderer, output: nil) }

    it 'co-ordinates the components' do
      args = {
        input: 'SomeFile.swift'
      }

      config = Swiftfake::Config.create(
        source_reader: source_reader,
        parser_klass: parser_klass,
        presenter_klass: presenter_klass,
        renderer: renderer
      )

      runner = described_class.new(args: args, config: config)
      runner.run

      expect(source_reader)
        .to have_received(:read_file).with(args[:input])

      expect(parser_klass)
        .to have_received(:new)

      expect(parser)
        .to have_received(:parse).with(source_file, structure_json)

      expect(presenter_klass)
        .to have_received(:new).with(swift_class)

      expect(renderer)
        .to have_received(:output).with(presenter)
    end
  end

end
