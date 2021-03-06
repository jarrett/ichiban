if RUBY_VERSION.match(/[0-9]+-[0-9]+-[0-9]+/) and Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.1.0')
  puts 'Ichiban requires '
  exit 1
end

# Standard lib
require 'fileutils'
require 'json'
require 'erb' # Just for the helpers
require 'stringio'

# Gems
require 'active_support/core_ext/array/extract_options'
require 'active_support/inflector'
require 'sass'
require 'erubis'
require 'rake'
require 'bundler'
require 'listen'
require 'ejs'
require 'uglifier'
require 'sourcemap'
require 'therubyracer'

# Ichiban files. Order matters!
require 'ichiban/config'
require 'ichiban/logger'
require 'ichiban/command'
require 'ichiban/project_generator'
require 'ichiban/dependencies'
require 'ichiban/loader'
require 'ichiban/watcher'
require 'ichiban/manual_compiler'
require 'ichiban/deleter'
require 'ichiban/project_file'
require 'ichiban/helpers'
require 'ichiban/nav_helper'
require 'ichiban/html_compiler'
require 'ichiban/asset_compiler'
require 'ichiban/js_compiler'
require 'ichiban/ejs_compiler'
require 'ichiban/markdown'
require 'ichiban/scripts'

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