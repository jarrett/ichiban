require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class JSCompilerTest < MiniTest::Test
  include ExampleDirectory
  include CompilationAssertions
  include JSONAssertions
  include LoggingAssertions
  
  def teardown
    super
    Ichiban.project_root = nil
  end
  
  def compiler(path_in_js)
    Ichiban::JSCompiler.new(Ichiban::ProjectFile.from_abs(File.join(
      Ichiban.project_root, 'assets/js/', path_in_js
    )))
  end
  
  def test_compile
    copy_example_dir
    assert_logged('') do
      compiler('home.js').compile
    end
    assert_compiled 'js/site.js'
    assert_compiled 'js/home.js'
    assert_compiled 'js/popups.js'
    assert_compiled_json 'js/site.js.map'
  end
  
  def test_compile_with_source_not_in_manifests
    copy_example_dir
    comp = compiler 'x.js'
    comp.compile # Just make sure it doesn't raise.
  end
end