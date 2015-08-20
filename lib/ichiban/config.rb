module Ichiban
  def self.config
    @config ||= ::Ichiban::Config.new
    yield @config if block_given?
    @config
  end
  
  class Config
    def self.load_file
      config_file = File.join(Ichiban.project_root, 'config.rb')
      raise "#{config_file} must exist" unless File.exists?(config_file)
      load config_file
    end
    
    attr_writer :dependencies
    
    def dependencies
      @dependencies || raise("Ichiban.config.dependencies not set. Set inside block in config.rb like this: cfg.dependencies = {...}")
    end
    
    attr_writer :js_manifests
    
    def js_manifests
      @js_manifests || raise("Ichiban.config.js_manifests not set. Set inside block in config.rb like this: cfg.js_manifests = {...}")
    end
    
    attr_writer :relative_url_root
    
    def relative_url_root
      @relative_url_root || raise("Ichiban.config.relative_url_root not set. Set inside block in config.rb like this: cfg.relative_url_root = '/'")
    end
    
    attr_writer :scss_root_files
    
    def scss_root_files
      @scss_root_files || raise("Ichiban.config.scss_root_files not set. Set inside block in config.rb like this: cfg.scss_root_files = ['screen.scss']")
    end
  end
end