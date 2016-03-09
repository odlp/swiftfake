module Swiftfake
  class SwiftFunction
    Argument = Struct.new(:name, :type)

    attr_reader :full_name, :name, :access, :arguments

    def initialize(full_name:, name:, access:, arguments:)
      @full_name = full_name
      @name = name
      @access = access
      @arguments = arguments
    end
  end
end
