module Superhosting
  module Helper
    module States
      def on_state(states:, state_mapper:, **options)
        current_state = state_mapper.state default: :none

        while (state = states[current_state.to_sym])
          method = state[:action]
          opts = method_options(method, options)

          self.debug_block(desc: { code: :transition, data: { name: method } }) do
            unless (resp = self.send(method, opts)).net_status_ok?
              resp.net_status_ok!
            end

            if state[:next].nil?
              state_mapper.state.delete!(full: true, logger: false)
            else
              self.set_state(state: state[:next], state_mapper: state_mapper.state)
            end
          end
          break if (current_state = state[:next]).nil?
        end
        {}
      rescue Exception => e
        undo_method = state[:undo] || :"undo_#{method}"

        if respond_to? undo_method
          self.debug_block(desc: { code: :transition_undo, data: { name: undo_method } }) do
            opts = method_options(undo_method, options)
            self.send(undo_method, opts)
          end
        end

        raise
      end

      def method_options(method_name, options)
        method = self.method(method_name)
        opts = {}
        method.parameters.each do |req, name|
          opt = options[name]
          opts.merge!(name => opt)
        end
        opts
      end

      def state(name:)
        self.existing_validation(name: name).net_status_ok!
        self.index[name][:state_mapper]
      end

      def set_state(state_mapper:, state:)
        old_state = state_mapper.value
        self.debug_operation(desc: { code: :change_state, data: { obj: state_mapper.parent.name, from: old_state, to: state } }) do |&b|
          self.with_logger(logger: false) do
            if state.nil?
              state_mapper.delete!(full: full)
            else
              state_mapper.put!(state)
            end
          end
          b.call(code: :ok)
        end
      end
    end
  end
end
