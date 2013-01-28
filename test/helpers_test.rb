require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestHelpers < MiniTest::Unit::TestCase
  include HTMLAssertions
  
  # Takes a block
  def in_context(current_path = '/', &block)
    ctx = Ichiban::HTMLCompiler::Context.new(:_current_path => current_path)
    ctx.instance_eval(&block)
  end
  
  def setup
    # This will also cause the config file to reload
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
    # If the path has a leading slash, it will be made absolute using relative_url_root.
    # Otherwise, it will remain relative.
    Ichiban.config do |cfg|
      cfg.relative_url_root = '/foo'
    end
    result_rel = nil
    result_abs = nil
    in_context do
      result_rel = normalize_path 'bar/'
      result_abs = normalize_path '/baz/'
    end
    assert_equal 'bar/', result_rel
    assert_equal '/foo/baz/', result_abs
  end
  
  def test_path_with_slashes
    skip
  end
  
  def test_relative_url_root
    result = nil
    Ichiban.config do |cfg|
      cfg.relative_url_root = '/foo'
    end
    in_context do
      result = relative_url_root
    end
    assert_equal '/foo', result
  end
end