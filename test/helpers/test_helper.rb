$:.unshift(File.dirname(__FILE__) + '/../..')
$:.unshift(File.dirname(__FILE__) + '/../../lib')

require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_record'
require 'active_record/fixtures'
require 'action_controller'
require 'action_controller/test_process'
require 'init'

require 'models/book'
require 'models/comment'
require 'models/user'
require 'models/person'
require 'models/camelized_model'
require 'models/multiple_call_model'
require 'controllers/books_controller'
require 'controllers/comments_controller'
require 'controllers/manager_controller'
require 'controllers/reset_controller'

ActionController::Routing::Routes.draw do |map|
  map.connect  ':controller/:action/:id'
end

config = YAML::load(IO.read(File.join(File.dirname(__FILE__), '..', 'database.yml')))[ENV['DB'] || 'test']
ActiveRecord::Base.configurations = config
ActiveRecord::Base.establish_connection(config)

schema_file = File.join(File.dirname(__FILE__), '..', 'schema.rb')
load(schema_file) if File.exist?(schema_file)

Test::Unit::TestCase.fixture_path = File.join(File.dirname(__FILE__), '..', 'fixtures')
$:.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase #:nodoc:
  # Turn off transactional fixtures if you're working with MyISAM tables in MySQL
  self.use_transactional_fixtures = true
  
  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  self.use_instantiated_fixtures  = true
end