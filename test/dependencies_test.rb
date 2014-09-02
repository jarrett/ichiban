require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')
require 'fileutils'

class TestDependencies < Minitest::Test
  include ExampleDirectory
  
  def stub_deps(deps_hash)
    mock_config = mock
    Ichiban.expects(:config).returns(mock_config).at_least_once
    mock_config.expects(:dependencies).returns(deps_hash).at_least_once
  end
  
  def assert_deps(exp_paths, deps_hash, ind_path)
    act_files = Ichiban::Dependencies.files_depending_on(
      File.join(Ichiban.project_root, ind_path)
    )
    act_paths = act_files.map do |file|
      file.rel
    end
    assert_equal exp_paths.sort, act_paths.sort
  end
  
  def test_files_depending_on_with_string
    init_example_dir
    deps_hash = {"data/employees.json" => "scripts/generate_employees.rb"}
    stub_deps(deps_hash)
    assert_deps ["scripts/generate_employees.rb"], deps_hash, "data/employees.json"
  end
  
  def test_files_depending_on_with_glob_simple
    init_example_dir
    deps_hash = {"layouts/default.html" => "html/**/*"}
    stub_deps(deps_hash)
    expected_paths = ["html/_employee.html", "html/_partial.html", 
      "html/changed_layout.html", "html/exception.html", "html/includes_partial.html",
      "html/markdown_page_2.markdown", "html/markdown_page.md", 
      "html/nested_layouts.html", "html/subfolder/page_in_subfolder.html",
      "html/watched_and_changed.html", "html/html_page.html"
    ]
    assert_deps expected_paths, deps_hash, "layouts/default.html"
  end
  
  def test_files_depending_on_with_glob_complex
    init_example_dir
    deps_hash = {"layouts/default.html" => "html/**/_*"}
    stub_deps(deps_hash)
    expected_paths = ["html/_employee.html", "html/_partial.html"]
    assert_deps expected_paths, deps_hash, "layouts/default.html"
  end
  
  def test_files_from_proc_returning_string
    exp_paths = "html/_partial.html"
    act_paths = Ichiban::Dependencies.files_from_proc(-> { "html/_partial.html" })
    assert_equal exp_paths, act_paths
  end
  
  def test_files_from_proc_non_valid_return
    assert_raises TypeError do 
      Ichiban::Dependencies.files_from_proc(-> { 2 })
    end
  end
  
  def test_files_from_proc_non_valid_array
    assert_raises TypeError do 
      Ichiban::Dependencies.files_from_proc(-> { [2, "Hello"] })
    end
  end
  
  def test_files_depending_on_proc_with_string
    init_example_dir
    deps_hash = {"layouts/default.html" => (-> {"html/_employee.html"})}
    stub_deps(deps_hash)
    expected_paths = ["html/_employee.html"]
    assert_deps expected_paths, deps_hash, "layouts/default.html"
  end
  
  def test_files_depending_on_proc_with_array
    init_example_dir
    deps_hash = {"layouts/default.html" => (-> {["html/_employee.html", "html/_partial.html"]})}
    stub_deps(deps_hash)
    expected_paths = ["html/_employee.html", "html/_partial.html"]
    assert_deps expected_paths, deps_hash, "layouts/default.html"
  end
  
  def test_files_depending_on_with_array
    init_example_dir
    deps_hash = {"layouts/nested_inner.html" => [(-> {["html/_employee.html", "html/_partial.html"]}), 
      "data/**/*", "helpers/my_helper.rb"]
    }
    stub_deps(deps_hash)
    exp_paths = ["html/_employee.html", "html/_partial.html", "data/employees.json", 
      "helpers/my_helper.rb"
    ]
    assert_deps exp_paths, deps_hash, "layouts/nested_inner.html"
  end
end