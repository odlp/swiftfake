require 'swiftfake/function_decorator'

module Swiftfake
  class Presenter
    attr_reader :swift_class

    def initialize(swift_class)
      @swift_class = swift_class
    end

    def get_binding
      binding()
    end

    def fake_class_signature
      "#{swift_class.access} class Fake#{swift_class.name}: #{swift_class.name}"
    end

    def functions
      @functions ||= swift_class.functions.map { |f| f.extend(FunctionDecorator) }
    end

    def functions_with_args
      functions.select {|f| f.has_args? }
    end
  end
end
