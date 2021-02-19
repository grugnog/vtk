# frozen_string_literal: true

require_relative '../../command'

module Vtk
  module Commands
    class Module
      # Adds a new module model to vets-api
      class Model < Vtk::Command
        attr_accessor :name, :options

        def initialize(name, options)
          @name = name
          @options = options

          super()
        end

        def execute(_input: $stdin, _output: $stdout)
          create_model(name, options)
        end

        private

        def create_model(name, options)
          component_name = options[:component_name] || name
          system("rails g module_component #{name} method:model component_name:#{component_name}")
        end
      end
    end
  end
end
