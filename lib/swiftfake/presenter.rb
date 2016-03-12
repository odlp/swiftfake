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
      swift_class.functions
    end

    def functions_with_args
      functions.select {|f| function_has_args?(f) }
    end

    def function_signature(func)
      "override #{func.full_name}"
    end

    def function_call_count(func)
      "#{func.name}CallCount"
    end

    def function_call_count_declaration(func)
      "#{func_store_prefix(func)} #{function_call_count(func)} = 0"
    end

    def function_has_args?(func)
      func.arguments.any?
    end

    def function_args_store_name(func)
      "#{func.name}ArgsForCall"
    end

    def function_args_store_append(func)
      store_name = function_args_store_name(func)

      if func.arguments.count == 1
        "#{store_name}.append(#{func.arguments.first.name})"
      else
        arg_names = func.arguments.map(&:name).join(", ")
        tuple = "(#{arg_names})"
        "#{store_name}.append(#{tuple})"
      end
    end

    def function_args_store_declaration(func)
      if func.arguments.count == 1
        args_type = func.arguments.first.type
      else # tuple time
        args = func.arguments
          .map{ |a| "#{a.name}: #{a.type}" }
          .join(', ')
        args_type = "(#{args})"
      end

      "#{func_store_prefix(func)} #{function_args_store_name(func)} = [#{args_type}]()"
    end

    def function_returns?(func)
      !func.return_value.nil?
    end

    def function_return_value(func)
      "return #{func.return_value}()"
    end

    private

    def func_store_prefix(func)
      if func.full_name.include? "class"
        "static var"
      else
        "var"
      end
    end
  end
end
