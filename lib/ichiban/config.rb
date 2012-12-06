module Ichiban
  def self.config
    @config ||= ::Ichiban::Config.new
    yield @config if block_given?
    @config
  end
  
  class Config
    attr_writer :relative_url_root
    
    def self.load_file
      config_file = File.join(Ichiban.project_root, 'config.rb')
      raise "#{config_file} must exist" unless File.exists?(config_file)
      load config_file
    end
    
    def relative_url_root
      @relative_url_root || raise("Ichiban.config.relative_url_root not set. Set inside block in config.rb like this: cfg.relative_url_root = '/'")
    end
  end
end