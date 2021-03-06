require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestNavHelper < Minitest::Test
  include HTMLAssertions
  
  # Takes a block
  def in_context(current_path = '/', &block)
    ctx = Ichiban::HTMLCompiler::Context.new(:_current_path => current_path)
    ctx.instance_eval(&block)
  end
  
  def setup
    super
    Ichiban.project_root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'example'))
  end
  
  def teardown
    super
    @_current_path = nil
    Ichiban.project_root = nil
  end
  
  def test_nav_does_not_link_current_page
    html = in_context('/bar/') do
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
    html = in_context('/bar/') do
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
    html = in_context('/bar/') do
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
    html = in_context('/two/three/') do
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
          <a href="/two/" class="above-selected">Two</a>
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
  
  def test_sub_menu_open_when_on_inner_page_non_matching_path
    # An inner page whose path is not a sub-path of the outer page.
    html = in_context('/two') do
      nav([
        ['One', '/one', [
          ['Two', '/two'],
          ['Three', '/three']
        ]]
      ])
    end
    assert_html('
      <ul>
        <li>
          <a href="/one/" class="above-selected">One</a>
          <ul>
            <li><span class="selected">Two</span></li>
            <li><a href="/three/">Three</a></li>
          </ul>
        </li>
      </ul>',
      html
    )
  end
  
  def test_sub_menu_open_when_on_outermost_page
    html = in_context('/two/') do
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
  
  def test_sub_menu_open_when_current_path_starts_with_item_path
    # When current path is /a/b/c, menu contains item /a/b, and :sub_paths => :collapse is
    # not given, the /a/b sub-menu should be open.
    html = in_context('/one/one/one') do
      nav([
        ['One', '/one', [
          ['One.One', '/one/one'],
          ['One.Two', '/one/two']
        ]],
        ['Two', '/two']
      ])
    end
    assert_html('
      <ul>
        <li>
          <a class="above-selected" href="/one/">One</a>
          <ul>
            <li><a href="/one/one/">One.One</a></li>
            <li><a href="/one/two/">One.Two</a></li>
          </ul>
        </li>
        <li><a href="/two/">Two</a></li>
      </ul>',
      html
    )
  end
  
  def test_sub_paths_collapse_option
    # When current path is /a/b/c, menu contains item /a/b, and :sub_paths => :collapse is
    # given, the /a/b sub-menu should be closed.
    html = in_context('/one/one/one') do
      nav([
        ['One', '/one', [
          ['One.One', '/one/one'],
          ['One.Two', '/one/two']
        ]],
        ['Two', '/two']
      ], sub_paths: :collapse)
    end
    assert_html('
      <ul>
        <li><a href="/one/">One</a></li>
        <li><a href="/two/">Two</a></li>
      </ul>',
      html
    )
  end

end