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
    assert !File.exists?(bad_dest), "Expected #{bad_dest} not to exist"
  end
  
  def test_updates_files_that_include_it
    # Make sure the depencency graph knows about this
    Ichiban::HTMLFile.new(File.join('html', 'includes_partial.html')).update
    
    File.open(partial_path, 'w') do |f|
      f << '<p>Version 2. Current path: <%= @_current_path %></p>'
    end
    file = Ichiban::ProjectFile.from_abs(partial_path)
    file.update
    assert_compiled 'includes_partial.html'
  end
  
  def test_updates_scripts_that_use_it
    # Make sure the depencency graph knows about this
    Ichiban::ScriptFile.new(File.join('scripts', 'generate_employees.rb')).update
    
    # Change the partial template
    path = File.join(Ichiban.project_root, 'html', '_employee.html')
    original_code = File.read(path)
    File.open(path, 'w') do |f|
      f << original_code.sub('Current path:', 'The current path:')
    end
    
    # Call update on the file (an instance of Ichiban::PartialHTMLFile)
    file = Ichiban::ProjectFile.from_abs(path)
    file.update
    
    # Check that each generated file contains the new HTML
    ['thomas-jefferson.html', 'george-washington.html'].each do |name|
      expected_code = File.read(
        File.join(Ichiban.project_root, 'expected', name)
      ).sub('Current path:', 'The current path:')
      assert_equal expected_code, File.read(File.join(Ichiban.project_root, 'compiled', name))
    end
  end
end