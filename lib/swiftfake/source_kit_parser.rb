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

      function_declarations
        .map {|f| FunctionParser.new.parse(f) }
        .compact
    end

    def find_raw_method_decl(method)
      start_offset = method["key.offset"]
      end_offset = method["key.bodyoffset"]

      return nil if start_offset.nil? || end_offset.nil?

      end_offset -= 1
      source_file[start_offset...end_offset]
    end

    class FunctionParser

      def parse(function_line)
        return nil unless can_override?(function_line)

        /func (?<name>.*)\(/ =~ function_line
        /(?<access>public|internal|private)/ =~ function_line
        /->\s(?<return_value>.+)$/ =~ function_line

        return_value.strip! unless return_value.nil?

        SwiftFunction.new(
          full_name: function_line.strip,
          name: name,
          access: access,
          arguments: parse_args(function_line),
          return_value: return_value
        )
      end

      private

      def can_override?(function_line)
        !function_line.include?('final') && !function_line.include?('private')
      end

      def parse_args(function_line)
        /func .*\((?<raw_args>.+)\)/ =~ function_line
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
