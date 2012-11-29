require 'fileutils'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/object/blank'
require 'active_support/inflector'
require 'erubis'
require 'maruku'
require 'sass'
require 'listen'

# Order matters!
require 'ichiban/command'
require 'ichiban/watcher'

module Ichiban
  def self.compiler
    
  end
  
  def self.project_root=(path)
    @project_root = path
  end
  
  def self.project_root
    @project_root
  end
end