require 'json'
require 'swiftfake/swift_class'
require 'swiftfake/swift_function'

module Swiftfake
  class SourceKitParser

    attr_reader :source_file, :structure_json

    def parse(source_file, raw_structure_json)
      @source_file = source_file
      @structure_json = JSON.parse(raw_structure_json)

      SwiftClass.new(
        name: class_name,
        access: access_level,
        functions: parse_functions
      )
    end

    private

    def class_name
      first_entity.fetch("key.name", nil)
    end

    def access_level
      raw_accessibility = first_entity.fetch("key.accessibility", nil)
      raw_accessibility.split('.').last unless raw_accessibility.nil?
    end

    def first_entity
      structure_json
        .fetch("key.substructure", [])
        .fetch(0, {})
    end

    def parse_functions
      function_declarations = first_entity
        .fetch("key.substructure", [])
        .select{ |part| part.fetch("key.kind", "").include? "function.method" }
        .map{|method| find_raw_method_decl(method) }
        .compact

      FunctionsParser.new(function_declarations).parse
    end

    def find_raw_method_decl(method)
      start_offset = method["key.offset"]
      name_offset = method["key.nameoffset"]
      name_length = method["key.namelength"]

      return nil if start_offset.nil? || name_offset.nil? || name_length.nil?

      end_offset = name_offset + name_length

      source_file[start_offset...end_offset]
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
