require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestHelpers < MiniTest::Unit::TestCase
  include HTMLAssertions
  
  # Takes a block
  def in_context(current_path = '/', &block)
    ctx = Ichiban::HTMLCompiler::Context.new(:_current_path => current_path)
    ctx.instance_eval(&block)
  end
  
  def setup
    Ichiban.project_root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'example'))
  end
  
  def teardown
    @_current_path = nil
    Ichiban.project_root = nil
  end
  
  def test_stylesheet_link_tag
    skip
  end
  
  def test_javascript_include_tag
    skip
  end
  
  def test_capture
    skip
  end
  
  def test_link_to
    skip
  end
  
  def test_normalize_path
    skip
  end
  
  def test_path_with_slashes
    skip
  end
  
  def test_relative_url_root
    skip
  end
end