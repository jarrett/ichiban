require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

# No need to do an end-to-end test here. Just mock the classes that Ichiban::Command calls.
class TestCommand < MiniTest::Unit::TestCase
  def test_new_command
    skip
  end
  
  def test_watch_command
    skip
  end
end