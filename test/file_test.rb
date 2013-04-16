require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestFile < MiniTest::Unit::TestCase
  # Bug fix: The LayoutFile class used to try to render partial templates as individual
  # pages, which resulted in exceptions.
  def test_layout_update_ignores_partial_templates
    # We don't want to set up real files for this in the example directory. It's easier
    # just to stub everything out.
    Ichiban::Dependencies.stubs(:graph).returns({'default' => ['_partial.html']})
    Ichiban::HTMLFile.expects(:new).never
    Ichiban.stubs(:project_root).returns('/dev/null')
    File.stubs(:exists?).returns(true)
    Ichiban::LayoutFile.new('layouts/default.html').update
  end
end