require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')
require 'fileutils'

class TestDependencies < MiniTest::Unit::TestCase
  include ExampleDirectory
  
  GRAPH_FILE = '.example_dependencies.json'
  
  def setup
    copy_example_dir
    Ichiban::Dependencies.clear_graphs
    FileUtils.rm GRAPH_FILE if File.exists?(GRAPH_FILE)
  end
  
  def teardown
    FileUtils.rm_rf Ichiban.project_root
    Ichiban.project_root = nil
  end
  
  def test_read_graph_from_file
    %w(dep1 dep2 dep3).each do |dep|
      Ichiban::Dependencies.update(GRAPH_FILE, 'ind1', dep)
    end
    %w(dep4 dep5).each do |dep|
      Ichiban::Dependencies.update(GRAPH_FILE, 'ind2', dep)
    end
    
    Ichiban::Dependencies.clear_graphs
    
    assert_equal({'ind1' => %w(dep1 dep2 dep3), 'ind2' => %w(dep4 dep5)}, Ichiban::Dependencies.graph(GRAPH_FILE))
  end
  
  def test_load_and_update_graph    
    %w(dep1 dep2 dep3).each do |dep|
      Ichiban::Dependencies.update(GRAPH_FILE, 'ind1', dep)
    end
    
    %w(dep4 dep5).each do |dep|
      Ichiban::Dependencies.update(GRAPH_FILE, 'ind2', dep)
    end
    
    Ichiban::Dependencies.update(GRAPH_FILE, 'ind1', 'dep6')
    Ichiban::Dependencies.update(GRAPH_FILE, 'ind2', 'dep7')
    
    # Check that it is updated in memory
    assert_equal({'ind1' => %w(dep1 dep2 dep3 dep6), 'ind2' => %w(dep4 dep5 dep7)}, Ichiban::Dependencies.graph(GRAPH_FILE))
    
    Ichiban::Dependencies.clear_graphs
    
    # Check that it is updated on disk
    assert_equal({'ind1' => %w(dep1 dep2 dep3 dep6), 'ind2' => %w(dep4 dep5 dep7)}, Ichiban::Dependencies.graph(GRAPH_FILE))
  end
end