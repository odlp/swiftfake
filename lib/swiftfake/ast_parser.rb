require 'swiftfake/swift_class'
require 'swiftfake/swift_function'

module Swiftfake
  class AstParser

    attr_reader :raw_ast

    def parse(raw_ast)
      @raw_ast = raw_ast
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
      function_lines = raw_ast_lines.select {|l| l.include? "func" }
      FunctionsParser.new(function_lines).parse
    end

    def raw_ast_lines
      @raw_ast_lines ||= raw_ast.split("\n")
    end

    class FunctionsParser
      attr_reader :function_lines

      def initialize(function_lines)
        @function_lines = function_lines
      end

      def parse
        overridable_functions.map do |line|
          /func (?<name>.*)\(/ =~ line
          /(?<access>public|internal|private)/ =~ line
          /->\s(?<return_value>.+)$/ =~ line

          SwiftFunction.new(
            full_name: line.strip,
            name: name,
            access: access,
            arguments: parse_args(line),
            return_value: return_value
          )
        end
      end

      private

      def overridable_functions
        function_lines.select do |l|
          !l.include?('final') && !l.include?('private')
        end
      end

      def parse_args(line)
        /func .*\((?<raw_args>.+)\)/ =~ line
        return [] if raw_args.nil?

        raw_args
          .split(",")
          .map { |raw|
            /(?<name>[\w]+):\s(?<type>.+)/ =~ raw
            SwiftFunction::Argument.new(name.strip, type.strip)
          }
      end
    end

  end
end
