describe 'Superhosting::Controller::Admin (cli)' do
  include SpecHelpers::Controller::User
  include SpecHelpers::Controller::Container
  include SpecHelpers::Controller::Admin

  def add_admin
    self.admin_add_with_exps(name: @admin_name, generate: true)
  end

  def add_admin_container
    add_admin
    container_add(name: @container_name)
    admin_container_add(name: @container_name)
  end

  it 'admin add' do
    expect { self.cli('admin', 'add', '-g', @admin_name) }.to_not raise_error
  end

  it 'admin delete' do
    add_admin
    expect { self.cli('admin', 'delete', @admin_name) }.to_not raise_error
  end

  it 'admin list' do
    add_admin_container
    expect { self.cli('admin', 'list') }.to_not raise_error
    expect { self.cli('admin', 'list', '--json') }.to_not raise_error
  end

  it 'admin passwd' do
    add_admin
    expect { self.cli('admin', 'passwd', '-g', @admin_name) }.to_not raise_error
  end

  it 'admin container add' do
    with_admin do |admin_name|
      with_container do |container_name|
        expect { self.cli('admin', 'container', 'add', container_name, '-a', admin_name) }.to_not raise_error
      end
    end
  end

  it 'admin container delete' do
    with_admin do |admin_name|
      with_container do |container_name|
        self.cli('admin', 'container', 'add', container_name, '-a', admin_name)
        expect { self.cli('admin', 'container', 'delete', container_name, '-a', admin_name) }.to_not raise_error
      end
    end
  end

  it 'admin container list' do
    add_admin_container
    expect { self.cli('admin', 'container', 'list', '-a', @admin_name) }.to_not raise_error
    expect { self.cli('admin', 'container', 'list', '-a', @admin_name, '--json') }.to_not raise_error
  end
end
