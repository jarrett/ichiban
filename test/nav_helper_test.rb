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
  
  def test_sub_menu_open_when_on_inner_page
    html = in_context('/two/three') do
      nav([
        ['One', '/one'],
        ['Two', '/two', [
          ['Two.One', '/two/one'],
          ['Two.Two', '/two/two', :id => 'two_two'],
          ['Two.Three', '/two/three']
        ]],
        ['Three', '/three', [
          ['Three.One', '/three/one'],
          ['Three.Two', '/three/two'],
          ['Three.Three', '/three/three']
        ], {'id' => 'three'}]
      ])
    end
    assert_html('
      <ul>
        <li><a href="/one/">One</a></li>
        <li>
          <a href="/two/" class="ancestor_of_selected">Two</a>
          <ul>
            <li><a href="/two/one/">Two.One</a></li>
            <li id="two_two"><a href="/two/two/">Two.Two</a></li>
            <li><span class="selected">Two.Three</span></li>
          </ul>
        </li>
        <li id="three"><a href="/three/">Three</a></li>
      </ul>',
      html
    )
  end
  
  def test_sub_menu_open_when_on_outermost_page
    html = in_context('/two') do
      nav([
        ['One', '/one'],
        ['Two', '/two', [
          ['Two.One', '/two/one'],
          ['Two.Two', '/two/two', :id => 'two_two'],
          ['Two.Three', '/two/three']
        ]],
        ['Three', '/three', [
          ['Three.One', '/three/one'],
          ['Three.Two', '/three/two'],
          ['Three.Three', '/three/three']
        ], {'id' => 'three'}]
      ])
    end
    assert_html('
      <ul>
        <li><a href="/one/">One</a></li>
        <li>
          <span class="selected">Two</span>
          <ul>
            <li><a href="/two/one/">Two.One</a></li>
            <li id="two_two"><a href="/two/two/">Two.Two</a></li>
            <li><a href="/two/three/">Two.Three</a></li>
          </ul>
        </li>
        <li id="three"><a href="/three/">Three</a></li>
      </ul>',
      html
    )
  end
end