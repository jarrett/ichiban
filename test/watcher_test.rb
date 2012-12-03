require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestWatcher < MiniTest::Unit::TestCase
  include CompilationAssertions
  
   # Takes a block. The watcher will be stopped after the block is executed.
  def run_watcher
    watcher = Ichiban::Watcher.new(:latency => 0.01)
    watcher.start
    begin
      # These sleep statements deal with the race condition. There doesn't seem to be any other
      # solution for that.
      sleep 0.5
      yield
      sleep 0.5
    ensure
      watcher.stop
    end
  end
  
  def setup
    Ichiban.project_root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'example'))
  end
  
  def teardown
    Dir.glob(File.join(Ichiban.project_root, 'compiled', '**/*')).each do |path|
      FileUtils.rm path
    end
    Ichiban.project_root = nil
  end
  
  def test_watched_and_changed
    src = File.join(Ichiban.project_root, 'html', 'watched_and_changed.html')
    dst = File.join(Ichiban.project_root, 'compiled', 'watched_and_changed.html')
    
    # Initial version of file
    File.open(src, 'w') do |f|
      f << '<p>This is the old text.</p>'
    end
    
    # Change the file
    run_watcher do
      #puts ANSI.color('writing changed filed', :magenta)
      File.open(src, 'w') do |f|
        f << '<p>This is the new text.</p>'
      end
      #puts ANSI.color('done writing', :magenta)
    end
    
    assert_compiled 'watched_and_changed.html'
  end
end