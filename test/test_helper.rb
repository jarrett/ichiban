require 'minitest/unit'
require 'turn/autorun'
#require 'minitest/autorun'
#require 'turn'

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '../lib'))

require 'ichiban'

module CompilationAssertions
  def assert_compiled(rel_path, msg = nil)
    compiled_path = File.join(Ichiban.project_root, 'compiled', rel_path)
    expected_path = File.join(Ichiban.project_root, 'expected', rel_path)
    assert File.exists?(compiled_path), msg || "Expected #{compiled_path} to exist"
    assert_equal File.read(compiled_path), File.read(expected_path)
  end
end

module LoggingAssertions
  # Takes a block. Redirects logger output form STDOUT, so you won't see it.
  def assert_logged(str, msg = nil)
    out = StringIO.new
    Ichiban.logger.out = out
    yield
    out.rewind
    assert out.read.include?(str), msg || "Expected log to include #{str}"
  end
end