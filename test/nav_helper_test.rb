require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestNavHelper < MiniTest::Unit::TestCase
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
  
  def test_nav_does_not_link_current_page
    html = in_context('/bar') do
      nav([
        ['Foo', '/foo'],
        ['Bar', '/bar'],
        ['Baz', '/baz']
      ])
    end
    assert_html('
      <ul>
        <li><a href="/foo/">Foo</a></li>
        <li><span class="selected">Bar</span></li>
        <li><a href="/baz/">Baz</a></li>
      </ul>',
      html
    )
  end
  
  def test_nav_ul_id
    html = in_context('/bar') do
      nav([
        ['Foo', '/foo'],
        ['Bar', '/bar'],
      ], :id => 'main_nav')
    end
    assert_html('
      <ul id="main_nav">
        <li><a href="/foo/">Foo</a></li>
        <li><span class="selected">Bar</span></li>
      </ul>',
      html
    )
  end
  
  def test_nav_li_attrs
    html = in_context('/bar') do
      nav([
        ['Foo', '/foo', {'data-whatever' => 'something'}],
        ['Bar', '/bar'],
      ])
    end
    assert_html('
      <ul>
        <li data-whatever="something"><a href="/foo/">Foo</a></li>
        <li><span class="selected">Bar</span></li>
      </ul>',
      html
    )
  end
end