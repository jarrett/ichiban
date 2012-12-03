require 'minitest/unit'
require 'turn/autorun'
#require 'minitest/autorun'
#require 'turn'

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '../lib'))

require 'ichiban'

module CompilationAssertions
  def assert_compiled(rel_path)
    compiled_path = File.join(Ichiban.project_root, 'compiled', rel_path)
    expected_path = File.join(Ichiban.project_root, 'expected', rel_path)
    assert File.exists?(compiled_path), "Expected #{compiled_path} to exist"
    assert_equal File.read(compiled_path), File.read(expected_path)
  end
end