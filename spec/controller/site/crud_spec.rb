require_relative 'spec_helpers'

describe Superhosting::Controller::Site do
  include SpecHelpers::Controller::Container
  include SpecHelpers::Controller::Site

  # positive

  it 'add' do
    with_container do |container_name|
      site_add_with_exps(name: @site_name, container_name: container_name)
    end
  end

  it 'delete' do
    with_container do |container_name|
      site_add_with_exps(name: @site_name, container_name: container_name)
      site_delete_with_exps(name: @site_name)
    end
  end

  it 'rename' do
    with_container do |container_name|
      with_site do |site_name|
        new_name = "new.#{site_name}"
        site_rename_with_exps(name: site_name, new_name: new_name)
      end
    end
  end

  it 'reconfig', :docker do
    with_container(model: 'bitrix_m') do |container_name|
      with_site do |site_name|
        site_registry_path = @site_controller.lib.containers.f(container_name).registry.sites.f(site_name).path
        time_site = File.mtime(site_registry_path)

        site_reconfig_with_exps(name: site_name)

        expect(site_registry_path).not_to eq time_site
      end
    end
  end

  it 'list' do
    with_container do |container_name|
      with_site do |site_name|
        expect(site_list_with_exps(container_name: container_name)[:data]).to include(site_name)
      end
    end
  end

  it 'alias_add' do
    with_container do |container_name|
      with_site do |site_name|
        alias_name = "alias-#{site_name}"
        site_alias_add_with_exps(name: alias_name)
      end
    end
  end

  it 'alias_delete' do
    with_container do |container_name|
      with_site do |site_name|
        alias_name = "alias-#{site_name}"
        site_alias_add_with_exps(name: alias_name)
        site_alias_delete_with_exps(name: alias_name)
      end
    end
  end

  # negative

  INVALID_SITE_NAMES = ['a', '-site.com', 'site.s', 'a.site.ru', 'sub.site.longregion', 'my_site.com']

  it 'add:invalid_site_name' do
    with_container do |container_name|
      INVALID_SITE_NAMES.each {|name| site_add_with_exps(name: name, container_name: container_name, code: :invalid_site_name) }
    end
  end

  it 'add:site_exists' do
    with_container do |container_name|
      site_add_with_exps(name: @site_name, container_name: container_name)
      site_add_with_exps(name: @site_name, container_name: container_name, code: :site_exists)
    end
  end

  it 'rename:invalid_site_name' do
    with_container do |container_name|
      with_site do |site_name|
        INVALID_SITE_NAMES.each {|name| site_rename_with_exps(name: site_name, new_name: name, code: :invalid_site_name) }
      end
    end
  end

  it 'rename:site_exists' do
    with_container do |container_name|
      with_site do |site_name|
        site_rename_with_exps(name: site_name, new_name: site_name, code: :site_exists)
      end
    end
  end

  it 'alias_add:invalid_site_name' do
    with_container do |container_name|
      with_site do |site_name|
        INVALID_SITE_NAMES.each {|name| site_alias_add_with_exps(name: name, code: :invalid_site_name) }
      end
    end
  end

  it 'alias_add:alias_exists' do
    with_container do |container_name|
      with_site do |site_name|
        alias_name = "alias-#{site_name}"
        site_alias_add_with_exps(name: alias_name)
        site_alias_add_with_exps(name: alias_name, code: :alias_exists)
      end
    end
  end

  it 'alias_add:site_exists' do
    with_container do |container_name|
      with_site do |site_name|
        site_alias_add_with_exps(name: site_name, code: :site_exists)
      end
    end
  end

  it '@site_index:container_site_name_conflict' do
    config_mapper = container_controller.config
    container_mapper = config_mapper.containers.test_container
    container_mapper.sites.f(@site_name).create!

    with_container do |container_name|
      site_add_with_exps(name: @site_name, container_name: container_name, code: :site_exists)
    end
  end

  # other

  it 'add#punycode' do
    with_container do |container_name|
      site_add_with_exps(name: 'домен.рф', container_name: container_name)
      conf_mapper = PathMapper.new('/etc').nginx.sites.f("#{container_name}-домен.рф.conf")
      expect_in_file(conf_mapper, 'xn--d1acufc.xn--p1ai')
    end
  end
end
