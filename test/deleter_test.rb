require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestDeleter < MiniTest::Unit::TestCase
  include ExampleDirectory
  
  def setup
    Ichiban.project_root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'example'))
  end
  
  def teardown
    Ichiban.project_root = nil
  end
  
  def test_delete_html
    src = File.join(Ichiban.project_root, 'html', 'delete.html')
    dst = File.join(Ichiban.project_root, 'compiled', 'delete.html')
    
    # Create the source file
    File.open(src, 'w') do |f|
      f << '<p>This file should be deleted momentarily.</p>'
    end
    
    # Create the destination file, as if it had been previously compiled
    FileUtils.cp(File.join(Ichiban.project_root, 'expected', 'deleted.html'), dst)
    
    # Delete the source file, as if a user did it
    FileUtils.rm src
    
    Ichiban::Deleter.new.delete_dest(src)
    
    assert !File.exists?(src), "Expected #{src} to be deleted"
    assert !File.exists?(dst), "Expected #{dst} to be deleted"
  end
end