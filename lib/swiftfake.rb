require 'swiftfake/version'
require 'swiftfake/compiler_interface'
require 'swiftfake/ast_parser'
require 'swiftfake/presenter'
require 'swiftfake/renderer'

module Swiftfake

  Config = Struct.new(:compiler_interface, :parser_klass, :presenter_klass, :renderer) do
    def self.create(compiler_interface: CompilerInterface.new, parser_klass: AstParser, presenter_klass: Presenter, renderer: Renderer.new)
       self.new(compiler_interface, parser_klass, presenter_klass, renderer)
    end
  end

  class Runner
    attr_reader :args, :config

    def initialize(args:, config: Config.create)
      @args = args
      @config = config
    end

    def run
      raw_ast = config.compiler_interface.generate_ast(args[:input])
      parser = config.parser_klass.new
      swift_class = parser.parse(raw_ast)
      presenter = config.presenter_klass.new(swift_class)
      config.renderer.output(presenter)
    end
  end
end
