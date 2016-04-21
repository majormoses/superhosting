module Superhosting
  module Controller
    class Model < Base
      def initialize(**kwargs)
        super
        @container_controller = get_controller(Container)
      end

      def list(abstract: false)
        { data: _list(abstract: abstract) }
      end

      def _list(abstract: false)
        models = []
        @config.models.grep_dirs.each do |model_mapper|
          next if !abstract && model_mapper.abstract?
          models << { 'name' => model_mapper.name, 'abstract' => model_mapper.abstract? }
        end
        models
      end

      def tree(name:)
        if (resp = existing_validation(name: name)).net_status_ok?
          { data: MapperInheritance::Model.new(@config.models.f(name)).collect_inheritors_tree[name] }
        else
          resp
        end
      end

      def inspect(name:, inheritance: false)
        if (resp = existing_validation(name: name)).net_status_ok?
          mapper = MapperInheritance::Model.new(@config.models.f(name)).inheritors_mapper(@config.models.f(name))
          if inheritance
            data = separate_inheritance(mapper) do |_base, inheritors|
              inheritors.inject([]) do |total, m|
                total << { 'type' => mapper_type(m.parent), 'name' => mapper_name(m), 'options' => get_mapper_options(m, erb: true) }
              end
            end
            { data: data }
          else
            { data: { 'name' => mapper.name, 'options' => get_mapper_options(mapper, erb: true) } }
          end
        else
          resp
        end
      end

      def options(name:, inheritance: false)
        if (resp = existing_validation(name: name)).net_status_ok?
          mapper = MapperInheritance::Model.new(@config.models.f(name)).inheritors_mapper(@config.models.f(name))
          if inheritance
            data = separate_inheritance(mapper) do |mapper, inheritors|
              inheritors.inject([]) do |inheritance, m|
                type = mapper_type(m)
                name = mapper_name(m)
                inheritance << { "#{"#{type}: " if type == 'mux'}#{name}" => get_mapper_options_pathes(m, erb: true) }
              end
            end
            { data: data }
          else
            { data: get_mapper_options_pathes(mapper, erb: true) }
          end
        else
          resp
        end
      end

      def inheritance(name:)
        if (resp = existing_validation(name: name)).net_status_ok?
          model_mapper = @config.models.f(name)
          inheritance = MapperInheritance::Model.new(model_mapper).inheritors
          inheritance.delete(model_mapper)
          { data: inheritance.map { |m| { 'type' => mapper_type(m.parent), 'name' => mapper_name(m) } } }
        else
          resp
        end
      end

      def reconfigure(name:)
        if (resp = useable_validation(name: name)).net_status_ok?
          index[name].each do |container_name|
            break unless (resp = @container_controller.reconfigure(name: container_name)).net_status_ok?
          end
        end
        resp
      end

      def update(name:)
        if (resp = useable_validation(name: name)).net_status_ok?
          index[name].each do |container_name|
            break unless (resp = @container_controller.update(name: container_name)).net_status_ok?
          end
        end
        resp
      end
    end
  end
end
