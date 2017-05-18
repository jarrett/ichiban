require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestPartialHTMLFile < Minitest::Test
  include CompilationAssertions
  include ExampleDirectory
  
  def setup
    super
    copy_example_dir
  end
  
  def teardown
    super
    FileUtils.rm_rf Ichiban.project_root
    Ichiban.project_root = nil
  end
  
  def partial_path
    File.join(Ichiban.project_root, 'html', '_partial.html')
  end
  
  def test_partial_name
    file = Ichiban::ProjectFile.from_abs(partial_path)
    assert_equal '_partial', file.partial_name
  end
  
  def test_instantiated_from_abs
    file = Ichiban::ProjectFile.from_abs(partial_path)
    assert_kind_of Ichiban::PartialHTMLFile, file
  end
  
  def test_does_not_copy_partial_file
    file = Ichiban::ProjectFile.from_abs(partial_path)
    file.update
    bad_dest = File.join(Ichiban.project_root, 'compiled', '_partial.html')
    assert !File.exist?(bad_dest), "Expected #{bad_dest} not to exist"
  end
end