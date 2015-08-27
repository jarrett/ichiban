require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

# No need to do an end-to-end test here. Just mock the classes that Ichiban::Command calls.
class TestCommand < Minitest::Test
  def test_new_command
    dest = File.expand_path 'my_site'
    mock_generator = mock('project generator')
    Ichiban::ProjectGenerator.expects(:new).with(dest).returns(mock_generator)
    mock_generator.expects(:generate).with
    Ichiban::Command.new(['new', 'my_site']).run
  end
  
  def test_watch_command
    cwd = Dir.getwd
    Ichiban.expects('project_root='.to_sym).with(cwd)
    mock_watcher = mock('watcher')
    Ichiban::Watcher.expects(:new).with.returns(mock_watcher)
    mock_watcher.expects(:start).with
    Ichiban::Command.new(['watch']).run
  end
  
  def test_compile_command_with_specific_paths
    cwd = Dir.getwd
    Ichiban.expects('project_root='.to_sym).with(cwd)
    mock_compiler = mock('manual compiler')
    Ichiban::ManualCompiler.expects(:new).with.returns(mock_compiler)
    mock_compiler.expects(:paths).with(['html/apples.html', 'html/bananas.html'])
    Ichiban::Command.new(['compile', 'html/apples.html', 'html/bananas.html']).run
  end
  
  def test_compile_command_with_all
    cwd = Dir.getwd
    Ichiban.expects('project_root='.to_sym).with(cwd)
    mock_compiler = mock('manual compiler')
    Ichiban::ManualCompiler.expects(:new).with.returns(mock_compiler)
    mock_compiler.expects(:all).with
    Ichiban::Command.new(['compile', '-a']).run
  end
end