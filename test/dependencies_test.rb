require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')
require 'fileutils'

class TestDependencies < MiniTest::Unit::TestCase
  include ExampleDirectory
end