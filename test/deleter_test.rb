require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')
require 'grit'

class TestDeleter < MiniTest::Unit::TestCase
  include ExampleDirectory
  
  def teardown
    Ichiban.project_root = nil
  end
  
  def test_delete_html_without_git
    skip
  end
  
  def test_delete_html_with_git
    # Give us a special directory to work in
    copy_example_dir
    
    begin
      repo = git_init
      
      src = File.join(Ichiban.project_root, 'html', 'watched_and_deleted.html')
      dst = File.join(Ichiban.project_root, 'compiled', 'watched_and_deleted.html')
      
      # Create the source file
      File.open(src, 'w') do |f|
        f << '<p>This file should be deleted momentarily.</p>'
      end
      
      # Create the destination file, as if it had been previously compiled
      FileUtils.cp(File.join(Ichiban.project_root, 'expected', 'watched_and_deleted.html'), dst)
      
      # Commit the newly created files
      git_commit_all
      
      # As a sanity check, assert that the two files are already in git, before we do
      # our main assertions.
      src_status = repo.status.detect { |f| f.path == 'html/watched_and_deleted.html' }
      dst_status = repo.status.detect { |f| f.path == 'compiled/watched_and_deleted.html' }
      assert !src_status.untracked, "Expected #{src} to be committed"
      assert !dst_status.untracked, "Expected #{dst} to be committed"
      
      Ichiban::Deleter.new.delete(src)
      
      src_status = repo.status.detect { |f| f.path == 'html/watched_and_deleted.html' }
      dst_status = repo.status.detect { |f| f.path == 'compiled/watched_and_deleted.html' }
      assert_equal 'D', src_status.type, "Expected #{src} to be staged for git delete"
      assert_equal 'D', dst_status.type, "Expected #{dst} to be staged for git delete"
    ensure
      FileUtils.rm_rf Ichiban.project_root
    end
  end

end