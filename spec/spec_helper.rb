require 'bundler/setup'

Bundler.setup

require 'active_support'

require 'superhosting'

Superhosting::Helper::I18n.i18n_initialize

require 'controller/spec_helpers'
require 'controller/container/spec_helpers'
require 'controller/user/spec_helpers'
require 'controller/admin/spec_helpers'

RSpec.configure do |c|
  c.filter_run_excluding :bootstrap unless File.read('/etc/sx/bootstrap').strip == 'yes'
end