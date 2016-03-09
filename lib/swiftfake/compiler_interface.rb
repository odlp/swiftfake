require 'open3'

module Swiftfake
  class CompilerInterface
    def generate_ast(source_file)
      ast, status = Open3.capture2("swiftc -print-ast #{source_file}")
      ast if status.success?
    end
  end
end
