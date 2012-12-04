require 'minitest/unit'
require 'turn/autorun'
require 'mocha/setup'

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '../lib'))

require 'ichiban'

module ExampleDirectory
  def copy_example_dir
    dir_suffix = rand(10**30)
    Ichiban.project_root = File.expand_path(File.join(File.dirname(__FILE__), '..', "example-#{dir_suffix}"))
    FileUtils.cp_r(File.expand_path(File.join(File.dirname(__FILE__), '..', 'example')), Ichiban.project_root)
  end
  
  # Add and commit everything
  def git_commit_all
    repo = Grit::Repo.new(Ichiban.project_root)
    repo.add(
      repo.status.collect { |f| f.path }
    )
    repo.commit_all('Commit all')
  end
  
  # Returns a Grit::Repo
  def git_init(options = {})
    options = {:commit_all => true}.merge(options)
    repo = Grit::Repo.init Ichiban.project_root
    if options[:commit_all]
      
    end
    repo
  end
end

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