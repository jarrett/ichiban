require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestScripts < MiniTest::Unit::TestCase
  include CompilationAssertions
  include ExampleDirectory
  
  def setup
    # There's a good chance of state leakage related to the dependency graph files.
    # To get around this, we copy the example directory into a temporary location.
    copy_example_dir
  end
  
  def teardown
    FileUtils.rm_rf Ichiban.project_root
    Ichiban.project_root = nil
  end
  
  def test_data_file_changed
    # Run the script once so that the dependencies graph is created.
    Ichiban.script_runner.script_file_changed(
      File.join(Ichiban.project_root, 'scripts/generate_employees.rb')
    )
    
    data_path = File.join(Ichiban.project_root, 'data/employees.json')
    
    # Change the data file. This by itself won't trigger a recompilation, since we're
    # not running the watcher.
    File.open(data_path, 'w') do |f|
      f << %Q(
        {"employees": [
          {"first": "Thomas", "last": "Jefferson"},
          {"first": "George", "last": "Washington"},
          {"first": "Ben",    "last": "Franklin"}
        ]}
      )
    end
    
    # Notify the script runner of the change. (The watcher would normally do this.)
    Ichiban.script_runner.data_file_changed(data_path)
    
    assert_compiled 'thomas-jefferson.html'
    assert_compiled 'george-washington.html'
    assert_compiled 'thomas-jefferson.html'
    assert_compiled 'ben-franklin.html'
  end
  
  def test_script_file_changed
    Ichiban.script_runner.script_file_changed(
      File.join(Ichiban.project_root, 'scripts/generate_employees.rb')
    )
    assert_compiled 'thomas-jefferson.html'
    assert_compiled 'george-washington.html'
  end
end