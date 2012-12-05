require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestAssetCompiler < MiniTest::Unit::TestCase
  include CompilationAssertions
  
  def setup
    Ichiban.project_root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'example'))
  end
  
  def teardown
    Dir.glob(File.join(Ichiban.project_root, 'compiled', '**/*')).each do |path|
      FileUtils.rm_rf path
    end
    Ichiban.project_root = nil
  end
  
  def test_scss_compilation
    FileUtils.mkdir(::File.join(Ichiban.project_root, 'compiled/css'))
    file = Ichiban::SCSSFile.new('assets/css/screen.scss')
    Ichiban::AssetCompiler.new(file).compile
    assert_compiled('css/screen.css')
  end
end
