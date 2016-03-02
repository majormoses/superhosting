module Superhosting
  module ScriptExecutor
    class Base
      include Helpers

      attr_accessor :commands
      attr_accessor :model, :lib, :config

      def initialize(model:, lib:, config:, **kwargs)
        kwargs.each do |k, v|
          instance_variable_set("@#{k}", v)
          self.class.class_eval("attr_accessor :#{k}")
        end

        self.commands = []
        self.model = model
        self.lib = lib
        self.config = config
      end

      def execute(script)
        self.instance_eval(script)
      end
    end
  end
end