require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestScripts < Minitest::Test
  include CompilationAssertions
  include ExampleDirectory
  
  def setup
    super
    # There's a good chance of state leakage related to the dependency graph files.
    # To get around this, we copy the example directory into a temporary location.
    copy_example_dir
  end
  
  def teardown
    super
    FileUtils.rm_rf Ichiban.project_root
    Ichiban.project_root = nil
  end
  
  def test_script_file_changed
    Ichiban.script_runner.script_file_changed(
      File.join(Ichiban.project_root, 'scripts/generate_employees.rb')
    )
    assert_compiled 'thomas-jefferson.html'
    assert_compiled 'george-washington.html'
  end
  
  def test_makes_folders_as_needed
    skip
  end
end