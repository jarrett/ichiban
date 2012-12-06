module Ichiban
  class Loader
    # Pass in an Ichiban::File
    def change(file)
      if file.is_a?(Ichiban::HelperFile) or file.is_a?(Ichiban::ModelFile)
        delete_all
        load_all
      end
    end
    
    # Load all models and helpers in Ichiban.project_root
    def initialize
      @loaded_constants = []
    end
    
    private
    
    def delete_all
      @loaded_constants.each do |const_name|
        Object.remove_const(const_name)
      end
    end
    
    def load_all
      # Load all models
      Dir.glob(::File.join(Ichiban.project_root), 'models/**/*.rb').each do |model_path|
        load_file(model_path)
      end
      
      # Load all helpers
      Dir.glob(::File.join(Ichiban.project_root), 'helpers/**/*.rb').each do |helper_path|
        load_file(helper_path)
      end
    end
    
    def load_file(path)
      const_name = ::File.basename(path, ::File.extname(path)).classify
      begin
        const = Object.const_get(const_name)
      rescue NameError
        raise "Expected #{path} to define #{const_name}"
      end
      @loaded_constants << const_name.to_sym
    end
  end
end