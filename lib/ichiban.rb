# Standard lib
require 'fileutils'
require 'json'

# Gems
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/object/blank'
require 'active_support/inflector'
require 'sass'
require 'listen'
require 'erubis'
require 'rake'

# Ichiban files. Order matters!
require 'ichiban/logger'
require 'ichiban/command'
require 'ichiban/watcher'
require 'ichiban/deleter'
require 'ichiban/file'
require 'ichiban/helpers'
require 'ichiban/html_compiler'
require 'ichiban/markdown'
require 'ichiban/dependencies'
require 'ichiban/helpers'

module Ichiban
  # Does the current project (as determined by project_root) have a .git directory?
  def self.gitted?
    ::File.directory?(::File.join(project_root, '.git'))
  end
  
  def self.grit
    unless @grit
      begin
        require 'grit'
        @grit = Grit::Repo.new(project_root)
      rescue LoadError
      end
    end
    @grit
  end
  
  def self.project_root=(path)
    @project_root = path
  end
  
  def self.project_root
    @project_root
  end
  
  # Try to load the libraries
  def self.try_require(*gems)
    gems.each do |gem|
      begin
        require gem
        return gem
      rescue LoadError
      end
    end
    false
  end
end