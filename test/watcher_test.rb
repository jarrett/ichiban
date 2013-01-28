require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

# Some of these tests use mocking to test the watcher in isolation. Others are more like integration
# tests, allowing the watcher to call the other classes that actually update the project files. The
# reason for this difference is that I started using mocks later in the project, and there didn't seem
# to be any compelling reason to waste time changing the old tests.

class TestWatcher < MiniTest::Unit::TestCase
  include CompilationAssertions
  include LoggingAssertions
  include ExampleDirectory
  
  # A simple way to check if a given bit of functionality is reloaded, taking into account
  # race conditions. Every 100 milliseconds, run the block. If it matches the expected value,
  # we're done. Try this max_attempts times. If the block never returns the expected value, flunk.
  def assert_reloaded(max_attempts)
    max_attempts.times do
      return if yield
      sleep 0.1
    end
    flunk "Expected the code to be reloaded and the block to return true within #{max_attempts} attempts"
  end
  
  # Takes a block. The watcher will be stopped after the block is executed.
  def run_watcher
    watcher = Ichiban::Watcher.new(:latency => 0.01)
    watcher.start(false) # nonblocking
    begin
      # These sleep statements deal with the race condition. There doesn't seem to be any other
      # solution for that.
      sleep 0.75
      yield
      sleep 0.75
    ensure
      watcher.stop
    end
  end
  
  def setup
    # The Listen gem leaks state between tests. To get around this, we copy the example directory
    # into a temporary location.
    copy_example_dir

    # The Listen gem runs the watcher in a thread. So any uncaught exceptions there would normally
    # just cause the thread to exit, rather than raise an exception in the main thread. This would
    # make the watcher seemingly inexplicably stop detecting filesystem events. The solution is to
    # tell Thread to raise an exception in the main thread whenever any other thread raises.
    @previous_abort_on_exceptions_setting = Thread.abort_on_exception
    Thread.abort_on_exception = true
  end
  
  def teardown
    FileUtils.rm_rf Ichiban.project_root
    Ichiban.project_root = nil
    Thread.abort_on_exception = @previous_abort_on_exceptions_setting
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
      File.open(src, 'w') do |f|
        f << '<p>This is the new text.</p>'
      end
    end
    
    assert_compiled 'watched_and_changed.html'
  end
  
  def test_watched_and_create
    src = File.join(Ichiban.project_root, 'html', 'watched_and_created.html')
    begin
      run_watcher do
        File.open(src, 'w') do |f|
          f << '<p>This file was just created.</p>'
        end
      end
      assert_compiled 'watched_and_created.html'
    ensure
      FileUtils.rm src
    end
  end
  
  def test_watched_and_deleted
    src = File.join(Ichiban.project_root, 'html', 'watched_and_deleted.html')
    
    # Create the source file
    File.open(src, 'w') do |f|
      f << '<p>This file should be deleted momentarily.</p>'
    end
    
    # No need to create the destination file, since we're just mocking the deleter
    
    Ichiban::Deleter.expects(:new).returns(deleter = mock('Deleter'))
    deleter.expects(:delete).with(src)
    
    run_watcher do
      FileUtils.rm src
    end
  end
  
  def test_watching_layouts
    # First, make sure the old version of the file exists, and that our dependency graph has
    # connected it to the layout.
    Ichiban::HTMLFile.new('html/changed_layout.html').update
    assert(
      File.exists?(File.join(Ichiban.project_root, 'compiled/changed_layout.html')),
      "Expected #{File.join(Ichiban.project_root, 'compiled/changed_layout.html')} to exist"
    )
    
    # Now update the layout
    layout_path = File.join(Ichiban.project_root, 'layouts/default.html')
    old_layout_code = File.read(layout_path)
    run_watcher do
      File.open(layout_path, 'w') do |f|
        f << old_layout_code.sub(/<h1>.*<\/h1>/, '<h1>The New Header</h1>')
      end
    end
    assert_compiled 'changed_layout.html'
  end
  
  def test_exception_logging
    src = File.join(Ichiban.project_root, 'html', 'exception.html')
    assert_logged('Test exception') do
      run_watcher do
        FileUtils.touch src
      end
    end
  end
  
  def test_watching_img
    run_watcher do
      FileUtils.touch File.join(Ichiban.project_root, 'assets/img/test.png')
    end
    assert_compiled 'img/test.png'
  end
  
  def test_watching_scss
    run_watcher do
      FileUtils.touch File.join(Ichiban.project_root, 'assets/css/screen.scss')
    end
    assert_compiled 'css/screen.css'
  end
  
  def test_watching_js
    run_watcher do
      FileUtils.touch File.join(Ichiban.project_root, 'assets/js/test.js')
    end
    assert_compiled 'js/test.js'
  end
  
  def test_watching_misc
    run_watcher do
      FileUtils.touch File.join(Ichiban.project_root, 'assets/misc/test.txt.gz')
    end
    assert_compiled 'test.txt.gz'
  end
  
  def test_watching_htaccess
    run_watcher do
      FileUtils.touch File.join(Ichiban.project_root, 'webserver/htaccess.txt')
    end
    assert_compiled '.htaccess'
  end
  
  def test_reload_model
    model_path = File.join(Ichiban.project_root, 'models', 'test_model.rb')
    run_watcher do
      assert_equal 6, TestModel.new.multiply(3)
      File.open(model_path, 'w') do |f|
        f << %(
          class TestModel
            def multiply(num)
              num * 4
            end
          end
        )
      end
      assert_reloaded(20) do
        TestModel.new.multiply(3) == 12
      end
    end
  end
  
  def test_helper_reload
    helper_path = File.join(Ichiban.project_root, 'helpers', 'my_helper.rb')
    run_watcher do
      assert_equal 6, Ichiban::HTMLCompiler::Context.new({}).multiply(3)
      File.open(helper_path, 'w') do |f|
        f << %(
          module MyHelper
            def multiply(num)
              num * 4
            end
          end
        )
      end
    end
    assert_reloaded(20) do
      Ichiban::HTMLCompiler::Context.new({}).multiply(3) == 12
    end
  end
end