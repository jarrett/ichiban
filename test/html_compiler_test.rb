require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')
require 'fileutils'

class TestHtmlCompiler < Minitest::Test
  include CompilationAssertions
  
  def setup
    super
    Ichiban.project_root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'example'))
  end
  
  def teardown
    super
    Dir.glob(File.join(Ichiban.project_root, 'compiled', '**/*')).each do |path|
      FileUtils.rm_rf path
    end
    Ichiban.project_root = nil
  end
  
  def test_compile_html
    file = Ichiban::HTMLFile.new('html/html_page.html')
    Ichiban::HTMLCompiler.new(file).compile
    assert_compiled 'html_page.html'
  end
  
  def test_compile_markdown
    file = Ichiban::HTMLFile.new('html/markdown_page.md')
    Ichiban::HTMLCompiler.new(file).compile
    assert_compiled 'markdown_page.html'
  end
  
  def test_nested_layouts
    file = Ichiban::HTMLFile.new('html/nested_layouts.html')
    Ichiban::HTMLCompiler.new(file).compile
    assert_compiled 'nested_layouts.html'
  end
  
  def test_exceptions_report_source_file
    file = Ichiban::HTMLFile.new('html/exception.html')
    exc = assert_raises(RuntimeError) do
      Ichiban::HTMLCompiler.new(file).compile
    end
    assert(exc.backtrace.any? do |trace|
      # This is guaranteed to be part of the absolute path we're expecting
      trace.include?('example/html/exception.html')
    end)
  end
  
  def test_makes_folders_as_needed
    file = Ichiban::HTMLFile.new('html/subfolder/page_in_subfolder.html')
    Ichiban::HTMLCompiler.new(file).compile
    assert_compiled 'subfolder/page_in_subfolder.html'
  end
end
