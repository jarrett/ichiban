require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/mini_test'
require 'lorax'

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '../lib'))

require 'ichiban'

class Minitest::Test
  def setup
    # Don't log to STDOUT when running tests.
    @original_logger_out = Ichiban.logger.out
    Ichiban.logger.out = StringIO.new
  end
  
  def teardown
    Ichiban.logger.out = @original_logger_out
  end
end

module ExampleDirectory
  def copy_example_dir
    dir_suffix = rand(10**30)
    new_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', "example-#{dir_suffix}"))
    FileUtils.cp_r(File.expand_path(File.join(File.dirname(__FILE__), '..', 'example')), new_dir)
    Ichiban.project_root = new_dir
  end
end

module CompilationAssertions
  def assert_compiled(rel_path, msg = nil)
    compiled_path = File.join(Ichiban.project_root, 'compiled', rel_path)
    expected_path = File.join(Ichiban.project_root, 'expected', rel_path)
    assert File.exists?(compiled_path), msg || "Expected #{compiled_path} to exist"
    compiled_data = File.read(compiled_path)
    expected_data = File.read(expected_path)
    # We don't want to print diffs for huge binary files
    if compiled_data.length < 4000 and expected_data.length < 4000
      assert expected_data == compiled_data, "Expected #{compiled_path} to be identical to #{expected_path} \n#{diff expected_data, compiled_data}"
    else
      assert expected_data == compiled_data, "Expected #{compiled_path} to be identical to #{expected_path}"
    end
  end
end

module LoggingAssertions
  # Takes a block. Redirects logger output form STDOUT, so you won't see it.
  def assert_logged(str, msg = nil)
    old_out = Ichiban.logger.out
    begin
      new_out = StringIO.new
      Ichiban.logger.out = new_out
      yield
      new_out.rewind
      assert new_out.read.include?(str), msg || "Expected log to include #{str}"
    ensure
      Ichiban.logger.out = old_out
    end
  end
end

module HTMLAssertions  
  def assert_html(expected_html, actual_html, message = nil)
    actual_doc = Nokogiri::HTML(actual_html)
    expected_doc = Nokogiri::HTML(expected_html)
    assert(
      Lorax::Signature.new(expected_doc.root).signature ==
      Lorax::Signature.new(actual_doc.root).signature,
      message || "HTML output not correct. Expected:\n\n#{expected_doc.to_xhtml}\n\nGot:\n\n#{actual_doc.to_xhtml}"
    )
  end
end