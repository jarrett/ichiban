require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/mini_test'
require 'lorax'
require 'json-compare'
require 'pp'

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '../lib'))

require 'ichiban'

class Minitest::Test
  def setup
    # Don't log to STDOUT when running tests. If you need to look at the log, you can use
    # assert_logged, which will temporarily replace the logger with a new StringIO
    # instance and assert against that. Or you can look directly into this StringIO
    # instance by calling Ichiban.logger.out or #inspect_log.
    @original_logger_out = Ichiban.logger.out
    Ichiban.logger.out = StringIO.new
  end
  
  def teardown
    Ichiban.logger.out = @original_logger_out
    Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), '..', "example-*"))).each do |example_dir|
      FileUtils.rm_rf example_dir
    end
  end
  
  def inspect_log
    log = Ichiban.logger.out
    log.rewind
    messages = log.read
    log.seek 0, IO::SEEK_END
    "\n\nLog:\n\n" + messages
  end
end

module ExampleDirectory
  def copy_example_dir
    dir_suffix = rand(10**30)
    new_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', "example-#{dir_suffix}"))
    FileUtils.cp_r(File.expand_path(File.join(File.dirname(__FILE__), '..', 'example')), new_dir)
    Ichiban.project_root = new_dir
  end
  
  def init_example_dir
    Ichiban.project_root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'example'))
  end
end

module CompilationAssertions  
  def assert_compiled(rel_path, msg = nil)
    compiled_path = File.join(Ichiban.project_root, 'compiled', rel_path)
    expected_path = File.join(Ichiban.project_root, 'expected', rel_path)
    assert File.exists?(expected_path), "Missing: #{expected_path}"
    assert File.exists?(compiled_path), msg || "Expected #{compiled_path} to exist"
    actual_data = File.read(compiled_path)
    expected_data = File.read(expected_path)
    if block_given?
      # The block should return true on success, a message string on failure.
      result = yield expected_data, actual_data
      if result != true
        result += inspect_log
        flunk(msg || ("Expected #{compiled_path} to match #{expected_path}\n\n" + result))
      end
    else
      # We don't want to print diffs for huge binary files
      if actual_data.length < 4000 and expected_data.length < 4000
        assert expected_data == actual_data, msg || "Expected #{compiled_path} to be identical to #{expected_path} \n#{diff expected_data, actual_data} #{inspect_log}"
      else
        assert expected_data == actual_data, msg || "Expected #{compiled_path} to be identical to #{expected_path} #{inspect_log}"
      end
    end
  end
end

module JSONAssertions
  def assert_compiled_json(rel_path, msg = nil)
    assert_compiled rel_path, msg do |expected, actual|
      compare_json expected, actual
    end
  end
  
  def assert_json(expected, actual)
    result = compare_json expected, actual
    unless result == true
      flunk result
    end
  end
  
  def compare_json(expected_json, actual_json)
    if expected_json.is_a?(String)
      expected_json = JSON.parse expected_json
    end
    if actual_json.is_a?(String)
      actual_json = JSON.parse actual_json
    end
    if expected_json == actual_json
      true
    else
      "Expected:\n\n#{pp_s(expected_json)}\n\n" +
      "Actual:\n\n#{pp_s(actual_json)}\n\n" +
      "Diff:\n\n" + 
      JsonCompare.get_diff(expected_json, actual_json).inspect
    end
  end
  
  def pp_s(*objs)
    s = StringIO.new
    objs.each {|obj|
      PP.pp(obj, s)
    }
    s.rewind
    s.read
  end
end

module LoggingAssertions
  # Takes a block. Redirects logger output from whatever it was before.
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