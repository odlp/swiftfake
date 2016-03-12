require 'erb'

module Swiftfake
  class Renderer
    def output(presenter)
      erb = ERB.new(template, nil, '-')
      erb.result(presenter.get_binding)
    end

    private

    def template
      path = File.expand_path("../../template.erb", __FILE__)
      File.read(path)
    end
  end
end
