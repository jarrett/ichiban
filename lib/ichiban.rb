# Standard lib
require 'fileutils'
require 'json'
require 'erb' # Just for the helpers

# Gems
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/object/blank'
require 'active_support/inflector'
require 'sass'
require 'listen'
require 'erubis'
require 'rake'

# Ichiban files. Order matters!
require 'ichiban/config'
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
  # In addition to setting the variable, this loads the config file
  def self.project_root=(path)
    @project_root = path
    if path # It's valid to set project_root to nil, though this would likely only happen in tests
      Ichiban::Config.load_file
    end
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