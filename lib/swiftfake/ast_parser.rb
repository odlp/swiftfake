require 'swiftfake/swift_class'
require 'swiftfake/swift_function'

module Swiftfake
  class AstParser

    attr_reader :raw_ast

    def initialize(raw_ast)
      @raw_ast = raw_ast
    end

    def parse
      klass_attributes = parse_klass_attributes
      klass_attributes[:functions] = parse_functions
      SwiftClass.new(klass_attributes)
    end

    private

    def parse_klass_attributes
      class_line = raw_ast_lines.find {|l| l.include? "class" }
      matches = /(?<access>public|internal|private)\sclass\s(?<name>.*)\s{/.match(class_line)
      {name: matches[:name], access: matches[:access]}
    end

    def parse_functions
      raw_ast_lines
        .select {|l| l.include? "func" }
        .map {|l| SwiftFunction.new(full_name: l.strip) }
    end

    def raw_ast_lines
      @raw_ast_lines ||= raw_ast.split("\n")
    end
  end
end
