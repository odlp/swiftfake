module Swiftfake
  module FunctionDecorator
    def signature
      "override #{full_name}"
    end

    def call_count
      "#{name}CallCount"
    end

    def call_count_declaration
      "#{var_prefix} #{call_count} = 0"
    end

    def has_args?
      arguments.any?
    end

    def args_store_append
      store_name = args_store_name

      if arguments.count == 1
        "#{store_name}.append(#{arguments.first.name})"
      else
        arg_names = arguments.map(&:name).join(", ")
        tuple = "(#{arg_names})"
        "#{store_name}.append(#{tuple})"
      end
    end

    def args_store_declaration
      "#{var_prefix} #{args_store_name} = [#{args_store_type}]()"
    end

    def returns?
      !return_value.nil?
    end

    def return_value_declaration
      "return #{return_value}()"
    end

    private

    def var_prefix
      full_name.include?("class") ? "static var" : "var"
    end

    def args_store_type
      if arguments.count == 1
        arguments.first.type
      else
        args_as_tuple
      end
    end

    def args_store_name
      "#{name}ArgsForCall"
    end

    def args_as_tuple
      args = arguments
        .map{ |a| "#{a.name}: #{a.type}" }
        .join(', ')
      "(#{args})"
    end
  end
end
