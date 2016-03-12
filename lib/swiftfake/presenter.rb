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
      "#{swift_class.access} Fake#{swift_class.name}: #{swift_class.name}"
    end

    def functions
      swift_class.functions
    end

    def function_signature(func)
      "override #{func.full_name}"
    end
  end
end
