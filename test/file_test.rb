require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestFile < MiniTest::Unit::TestCase
  # Bug fix: The LayoutFile class used to try to render partial templates as individual
  # pages, which resulted in exceptions.
  def test_layout_update_ignores_partial_templates
    # We don't want to set up real files for this in the example directory. It's easier
    # just to stub everything out.
    Ichiban::Dependencies.stubs(:graph).returns({'default' => ['_partial.html']})
    Ichiban::HTMLFile.expects(:new).never
    Ichiban.stubs(:project_root).returns('/dev/null')
    File.stubs(:exists?).returns(true)
    Ichiban::LayoutFile.new('layouts/default.html').update
  end
  
  # Bug fix: The HTMLFile class used to include only the filename, not the folders,
  # in the return value of #web_path.
  # 
  # Another bug: It used to put '/./' a the beginning of paths in the root folder.
  def test_html_file_knows_correct_web_path
    Ichiban.stubs(:project_root).returns('/dev/null')
    
    file = Ichiban::HTMLFile.new 'html/foo/bar/baz.html'
    assert_equal '/foo/bar/baz/', file.web_path
    
    file = Ichiban::HTMLFile.new 'html/foo/bar/index.html'
    assert_equal '/foo/bar/', file.web_path
    
    file = Ichiban::HTMLFile.new 'html/baz.html'
    assert_equal '/baz/', file.web_path
    
    Ichiban.project_root = nil
  end
end