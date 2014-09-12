require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestFile < Minitest::Test
  include ExampleDirectory
  
  def teardown
    Ichiban.project_root = nil
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
  
  # Bug fix: from_abs used to instantiate ProjectFile subclasses when passed a directory.
  def test_from_abs_ignores_directories
    init_example_dir
    assert_nil Ichiban::ProjectFile.from_abs File.join(Ichiban.project_root, 'assets/css')
    assert_nil Ichiban::ProjectFile.from_abs File.join(Ichiban.project_root, 'assets/js')
    assert_nil Ichiban::ProjectFile.from_abs File.join(Ichiban.project_root, 'assets/img')
    assert_nil Ichiban::ProjectFile.from_abs File.join(Ichiban.project_root, 'assets/misc')
    assert_nil Ichiban::ProjectFile.from_abs File.join(Ichiban.project_root, 'compiled')
    assert_nil Ichiban::ProjectFile.from_abs File.join(Ichiban.project_root, 'data')
    assert_nil Ichiban::ProjectFile.from_abs File.join(Ichiban.project_root, 'helpers')
    assert_nil Ichiban::ProjectFile.from_abs File.join(Ichiban.project_root, 'html')
    assert_nil Ichiban::ProjectFile.from_abs File.join(Ichiban.project_root, 'models')
    assert_nil Ichiban::ProjectFile.from_abs File.join(Ichiban.project_root, 'layouts')
    assert_nil Ichiban::ProjectFile.from_abs File.join(Ichiban.project_root, 'scripts')
    assert_nil Ichiban::ProjectFile.from_abs File.join(Ichiban.project_root, 'webserver')
  end
end