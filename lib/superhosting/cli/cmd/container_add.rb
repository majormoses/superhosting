module Superhosting
  module Cli
    module Cmd
      class ContainerAdd < Base
        include Helper::Options::Model

        def self.has_required_param?
          true
        end
      end
    end
  end
end