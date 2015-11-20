require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class WatcherTest < Minitest::Test
  include CompilationAssertions
  include LoggingAssertions
  include ExampleDirectory
  
  def setup
    super
    
    # To isolate the state of each test, we operate on a copy of the example folder. This
    # also sets Ichiban.project_root.
    copy_example_dir
  end
  
  def teardown
    super
    FileUtils.rm_rf Ichiban.project_root
    Ichiban.project_root = nil
  end
  
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
  
  def init_watcher
    @watcher ||= Ichiban::Watcher.new
  end
  
  def mock_watcher_add(path)
    init_watcher
    @watcher.on_change([], [path], [])
    @watcher
  end
  
  def mock_watcher_mod(path)
    init_watcher
    @watcher.on_change([path], [], [])
    @watcher
  end
  
  def mock_watcher_del(path)
    init_watcher
    @watcher.on_change([], [], [path])
    @watcher
  end
  
  def test_watched_and_changed
    src = File.join(Ichiban.project_root, 'html', 'watched_and_changed.html')
    File.open(src, 'w') do |f|
      f << '<p>This is the new text.</p>'
    end
    mock_watcher_mod src
    assert_compiled 'watched_and_changed.html'
  end
  
  def test_watched_and_create
    src = File.join(Ichiban.project_root, 'html', 'watched_and_created.html')
    File.open(src, 'w') do |f|
      f << '<p>This file was just created.</p>'
    end
    mock_watcher_add src
    assert_compiled 'watched_and_created.html'
  end
  
  def test_watched_and_deleted_file
    src = File.join(Ichiban.project_root, 'html', 'watched_and_deleted.html')
    dst = File.join(Ichiban.project_root, 'compiled', 'watched_and_deleted.html')
    [src, dst].each do |path|
      File.open(path, 'w') do |f|
        f << '<p>This file should be deleted momentarily.</p>'
      end
    end    
    assert File.exists?(dst)
    mock_watcher_del src
    assert !File.exists?(dst)
  end
  
  def test_watched_and_deleted_folder
    skip
  end
  
  def test_exception_logging
    assert_logged('Test exception') do
      src = File.join(Ichiban.project_root, 'html', 'exception.html')
      mock_watcher_mod src
    end
  end
  
  def test_watching_markdown
    src = File.join(Ichiban.project_root, 'html/markdown_page.md')
    mock_watcher_mod src
    assert_compiled 'markdown_page.html'
    src = File.join(Ichiban.project_root, 'html/markdown_page_2.markdown')
    mock_watcher_mod src
    assert_compiled 'markdown_page_2.html'
  end
  
  def test_watching_img
    src = File.join(Ichiban.project_root, 'assets/img/test.png')
    mock_watcher_mod src
    assert_compiled 'img/test.png'
  end
  
  def test_watching_scss
    src = File.join(Ichiban.project_root, 'assets/css/screen.scss')
    mock_watcher_mod src
    assert_compiled 'css/screen.css'
  end
  
  def test_watching_js
    src = File.join(Ichiban.project_root, 'assets/js/test-source.js')
    mock_watcher_mod src
    assert_compiled 'js/test-compiled.js'
  end
  
  def test_watching_ejs
    src = File.join(Ichiban.project_root, 'assets/ejs/template.ejs')
    mock_watcher_mod src
    assert_compiled 'ejs/template.js'
  end
  
  def test_watching_misc
    src = File.join(Ichiban.project_root, 'assets/misc/test.txt.gz')
    mock_watcher_mod src
    assert_compiled 'test.txt.gz'
  end
  
  def test_watching_misplaced_assets
    src = File.join(Ichiban.project_root, 'html/subfolder/misplaced.txt')
    mock_watcher_mod src
    assert_compiled 'subfolder/misplaced.txt'
  end
  
  def test_watching_htaccess
    FileUtils.rm File.join(Ichiban.project_root, 'compiled/.htaccess')
    src = File.join(Ichiban.project_root, 'webserver/htaccess.txt')
    mock_watcher_mod src
    assert_compiled '.htaccess'
  end
  
  def test_reload_model
    init_watcher
    
    model_path = File.join(Ichiban.project_root, 'models', 'test_model.rb')
    
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
    mock_watcher_mod model_path
    assert_reloaded(20) do
      TestModel.new.multiply(3) == 12
    end
  end
  
  def test_helper_reload
    helper_path = File.join(Ichiban.project_root, 'helpers', 'my_helper.rb')
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
    mock_watcher_mod helper_path
    assert_reloaded(20) do
      Ichiban::HTMLCompiler::Context.new({}).multiply(3) == 12
    end
  end
end