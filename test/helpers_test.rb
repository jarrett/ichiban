require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestHelpers < Minitest::Test
  include HTMLAssertions
  
  # Takes a block
  def in_context(current_path = '/', &block)
    ctx = Ichiban::HTMLCompiler::Context.new(:_current_path => current_path)
    ctx.instance_eval(&block)
  end
  
  def setup
    super
    # This will also cause the config file to reload
    Ichiban.project_root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'example'))
  end
  
  def teardown
    super
    @_current_path = nil
    Ichiban.project_root = nil    
  end
  
  def test_stylesheet_link_tag
    result = nil
    Ichiban.config do |cfg|
      cfg.relative_url_root = '/foo'
    end
    in_context do
      result = stylesheet_link_tag 'bar.css'
    end
    assert_html '<link href="/foo/css/bar.css" rel="stylesheet" type="text/css" media="screen"/>', result
  end
  
  def test_javascript_include_tag
    result = nil
    Ichiban.config do |cfg|
      cfg.relative_url_root = '/foo'
    end
    in_context do
      result = javascript_include_tag 'bar.js'
    end
    assert_html '<script type="text/javascript" src="/foo/js/bar.js"></script>', result
  end
  
  def test_capture
    template = '<p>Foo<% captured = capture do %>Bar<% end %></p><p><%= captured %></p>'
    ctx = Ichiban::HTMLCompiler::Context.new(:_current_path => '/')
    result = Ichiban::HTMLCompiler::Eruby.new(template).evaluate(ctx)
    assert_html '<p>Foo</p><p>Bar</p>', result
  end
  
  def test_concat
    template = '<p><% concat "Foo" %></p>'
    ctx = Ichiban::HTMLCompiler::Context.new(:_current_path => '/')
    result = Ichiban::HTMLCompiler::Eruby.new(template).evaluate(ctx)
    assert_html '<p>Foo</p>', result
  end
  
  def test_link_to
    result = nil
    in_context do
      result = link_to 'Example', 'http://example.com/', 'class' => 'the_class', 'id' => 'the_id'
    end
    assert_html '<a href="http://example.com/" class="the_class", id="the_id">Example</a>', result
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
    # Adds leading and trailing slashes if none are present
    result_1 = nil
    result_2 = nil
    result_3 = nil
    result_4 = nil
    in_context do
      result_1 = path_with_slashes 'foo'
      result_2 = path_with_slashes '/foo'
      result_3 = path_with_slashes 'foo/'
      result_4 = path_with_slashes '/foo/'
    end
    assert_equal '/foo/', result_1
    assert_equal '/foo/', result_2
    assert_equal '/foo/', result_3
    assert_equal '/foo/', result_4
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