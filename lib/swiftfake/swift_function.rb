module Swiftfake
  class SwiftFunction
    attr_reader :full_name

    def initialize(full_name:)
      @full_name = full_name
    end
  end
end
