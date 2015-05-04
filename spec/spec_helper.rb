$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bundler/setup'
Bundler.setup

require 'active_support/core_ext/module/delegation.rb'
require 'active_support/core_ext/object/blank.rb'
require 'calendrical'

RSpec.configure do |config|
  config.include(Calendrical::Days)
  config.include(Calendrical::Months)
end