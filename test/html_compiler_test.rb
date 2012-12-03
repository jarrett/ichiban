require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')
require 'fileutils'

class TestHtmlCompiler < MiniTest::Unit::TestCase
  include CompilationAssertions
  
  def setup
    Ichiban.project_root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'example'))
  end
  
  def teardown
    Dir.glob(File.join(Ichiban.project_root, 'compiled', '**/*')).each do |path|
      #FileUtils.rm path
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
end
