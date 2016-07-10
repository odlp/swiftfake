require 'open3'

module Swiftfake
  class SourceReader
    def read_file(source_file)
      source = File.read(source_file)
      structure_json, status = Open3.capture2("sourcekitten structure --file #{source_file}")

      [source, structure_json] if status.success?
    end
  end
end
