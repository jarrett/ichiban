require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class ManualCompilerTest < MiniTest::Test
  include ExampleDirectory
  include CompilationAssertions
  include LoggingAssertions
  
  def teardown
    super
    Ichiban.project_root = nil
  end
  
  def test_compile_paths
    copy_example_dir
    Ichiban::ManualCompiler.new.paths([
      'html/html_page.html', 'html/markdown_page.md', 'html/uses_helper.html'
    ])
    assert_compiled 'html_page.html'
    assert_compiled 'markdown_page.html'
    assert_compiled 'uses_helper.html'
  end
  
  def test_compile_all
    copy_example_dir
    assert_logged('Test exception') do
      Ichiban::ManualCompiler.new.all
    end
    [
      # Content.
      'george-washington.html',
      'html_page.html',
      'markdown_page.html',
      'markdown_page_2.html',
      'nested_layouts.html',
      'subfolder/page_in_subfolder.html',
      'test.txt.gz',
      'thomas-jefferson.html',
      
      # CSS.
      'css/screen.css',
      
      # EJS.
      'ejs/template.js',
      
      # JS.
      'js/site.js',
      'js/test.js',
      
      # Images.
      'img/test.png',
      
      # Webserver config.
      '.htaccess'
    ].each do |compiled_path|
      assert_compiled compiled_path
    end
  end
end