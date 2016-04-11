module Superhosting
  module Patches
    module PathMapper
      module FileNode
        include Helper::Logger

        def _put!(content)
          self.debug_operation(desc: { code: :file, data: { path: @path } }) do |&blk|
            super.tap {|res| blk.call(code: res[:code], diff: res[:d][:diff]) }
          end
        end

        def _safe_put!(content)
          self.debug_operation(desc: { code: :file, data: { path: @path } }) do |&blk|
            super.tap {|res| blk.call(code: res[:code], diff: res[:d][:diff]) }
          end
        end

        def _remove_line!(line)
          self.debug_operation(desc: { code: :file, data: { path: @path } }) do |&blk|
            super.tap {|res| blk.call(code: res[:code], diff: res[:d][:diff]) }
          end
        end

        def _append_line!(content)
          self.debug_operation(desc: { code: :file, data: { path: @path } }) do |&blk|
            super.tap {|res| blk.call(code: res[:code], diff: res[:d][:diff]) }
          end
        end

        def _rename!(new_path)
          self.debug_operation(desc: { code: :file, data: { path: @path, to: new_path } }) do |&blk|
            super.tap {|res| blk.call(code: res[:code], diff: res[:d][:diff]) }
          end
        end

        def _delete!(full: false)
          self.debug_operation(desc: { code: :file, data: { path: @path } }) do |&blk|
            super.tap {|res| blk.call(code: res[:code], diff: res[:d][:diff]) }
          end
        end
      end
    end
  end
end

::PathMapper::FileNode.send(:prepend, Superhosting::Patches::PathMapper::FileNode)