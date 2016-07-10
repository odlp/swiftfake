require 'swiftfake/version'
require 'swiftfake/source_reader'
require 'swiftfake/source_kit_parser'
require 'swiftfake/presenter'
require 'swiftfake/renderer'

module Swiftfake

  Config = Struct.new(:source_reader, :parser_klass, :presenter_klass, :renderer) do
    def self.create(source_reader: SourceReader.new, parser_klass: SourceKitParser, presenter_klass: Presenter, renderer: Renderer.new)
       self.new(source_reader, parser_klass, presenter_klass, renderer)
    end
  end

  class Runner
    attr_reader :args, :config

    def initialize(args:, config: Config.create)
      @args = args
      @config = config
    end

    def run
      source_file, structure_json = config.source_reader.read_file(args[:input])
      parser = config.parser_klass.new
      swift_class = parser.parse(source_file, structure_json)
      presenter = config.presenter_klass.new(swift_class)
      config.renderer.output(presenter)
    end
  end
end
