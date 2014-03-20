# Standard lib
require 'fileutils'
require 'json'
require 'erb' # Just for the helpers

# Gems
#require 'active_support/core_ext/class/attribute'
#require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array/extract_options'
require 'active_support/inflector'
require 'sass'
require 'erubis'
require 'rake'
require 'bundler'
gem 'listen', '= 0.7.3'
require 'listen'
require 'ejs'

# Ichiban files. Order matters!
require 'ichiban/bundle'
require 'ichiban/config'
require 'ichiban/logger'
require 'ichiban/command'
require 'ichiban/project_generator'
require 'ichiban/dependencies'
require 'ichiban/loader'
require 'ichiban/watcher'
require 'ichiban/deleter'
require 'ichiban/file'
require 'ichiban/helpers'
require 'ichiban/nav_helper'
require 'ichiban/html_compiler'
require 'ichiban/asset_compiler'
require 'ichiban/ejs_compiler'
require 'ichiban/markdown'
require 'ichiban/scripts'

module Ichiban
  # In addition to setting the variable, this loads the config file
  def self.project_root=(path)
    unless @project_root == path
      # If we're changing the project root, then we need to clear all dependency graphs from memory.
      # This doesn't delete any files.
      Ichiban::Dependencies.clear_graphs
    end
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