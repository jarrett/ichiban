module Ichiban
  def self.config
    @config ||= ::Ichiban::Config.new
    yield @config if block_given?
    @config
  end
  
  def self.configure_for_project(project_root)
    config.project_root = project_root
    config_file = File.join(project_root, 'config.rb')
    raise "#{config_file} must exist" unless File.exists?(config_file)
    load config_file
  end
  
  # It's a bit messy to have this class method that's just an alias to a method on the config object.
  # But so many different bits of code (including client code) need to know the project root, it makes
  # pragmatic sense to have a really compact way to get it.
  def self.project_root
    config.project_root
  end
  
  class Config
    attr_accessor :project_root

    attr_writer :relative_url_root
    
    def relative_url_root
      @relative_url_root || raise('Ichiban.config.relative_url_root not set. Set inside block in config.rb like this: cfg.relative_url_root = \'/\'')
    end
  end
end