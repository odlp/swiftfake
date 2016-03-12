module Swiftfake
  class SwiftFunction
    Argument = Struct.new(:name, :type)

    attr_reader :full_name, :name, :access, :arguments, :return_value

    def initialize(full_name:, name:, access:, arguments:, return_value:)
      @full_name = full_name
      @name = name
      @access = access
      @arguments = arguments
      @return_value = return_value
    end
  end
end
