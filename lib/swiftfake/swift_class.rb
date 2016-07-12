module Swiftfake
  class SwiftClass
    attr_reader :name, :access, :functions, :imports

    def initialize(name:, access:, functions:, imports: [])
      @name = name
      @access = access
      @functions = functions
      @imports = imports
    end
  end
end
