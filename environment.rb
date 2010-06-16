begin
  require 'bundler'
rescue LoadError
  require 'rubygems'
  require 'bundler'
end

Bundler.setup(:default)

require 'dm-core'
require 'dm-types'
require 'dm-timestamps'
require 'dm-migrations'
require 'dm-validations'
require 'dm-aggregates'
require 'yajl/json_gem'
require 'haml'
