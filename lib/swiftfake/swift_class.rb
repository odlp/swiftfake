module Swiftfake
  class SwiftClass
    attr_reader :name, :access, :functions

    def initialize(name:, access:, functions:)
      @name = name
      @access = access
      @functions = functions
    end
  end
end
