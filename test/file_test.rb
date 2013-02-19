require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestWatcher < MiniTest::Unit::TestCase
  include CompilationAssertions
  include LoggingAssertions
  include ExampleDirectory
  
  # If a content file is recorded in the dependency graph and gets deleted, Ichiban
  # should handle it gracefully.
  def test_layout_update_with_deleted_file
    flunk 'this currently doesnt work and its a terrible bug'
  end
end