require 'spec_helper'
require 'swiftfake'

describe Swiftfake::Runner do

  describe '#run' do

    let(:ast_tree) { 'A tree' }
    let(:swift_class) { instance_double(Swiftfake::SwiftClass) }
    let(:compiler_interface) { instance_double(Swiftfake::CompilerInterface, generate_ast: ast_tree) }

    let(:parser) { instance_double(Swiftfake::AstParser, parse: swift_class) }
    let(:parser_klass) { class_double(Swiftfake::AstParser, new: parser) }
    let(:presenter) { instance_double(Swiftfake::Presenter, get_binding: "binding") }
    let(:presenter_klass) { class_double(Swiftfake::Presenter, new: presenter) }
    let(:renderer) { instance_double(Swiftfake::Renderer, output: nil) }

    it 'co-ordinates the components' do
      args = {
        input: 'SomeFile.swift'
      }

      config = Swiftfake::Config.create(
        compiler_interface: compiler_interface,
        parser_klass: parser_klass,
        presenter_klass: presenter_klass,
        renderer: renderer
      )

      runner = described_class.new(args: args, config: config)
      runner.run

      expect(compiler_interface)
        .to have_received(:generate_ast).with(args[:input])

      expect(parser_klass)
        .to have_received(:new)

      expect(parser)
        .to have_received(:parse).with(ast_tree)

      expect(presenter_klass)
        .to have_received(:new).with(swift_class)

      expect(renderer)
        .to have_received(:output).with(presenter)
    end
  end

end
