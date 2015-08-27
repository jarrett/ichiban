module Ichiban
  class Loader
    # Pass in an Ichiban::ProjectFile.
    def change(file)
      if file.is_a?(Ichiban::HelperFile) or file.is_a?(Ichiban::ModelFile)
        delete_all
        load_all
        Ichiban.logger.reload(file.abs)
      end
    end
    
    # Load all models and helpers in Ichiban.project_root
    def initialize
      @loaded_constants = []
      load_all
    end
    
    private
    
    # Calls Object.remove_const on all tracked modules. Also clears the compiler's list of user-defined helpers.
    def delete_all
      @loaded_constants.each do |const_name|
        if Object.const_defined?(const_name)
          Object.send(:remove_const, const_name)
        end
      end
      Ichiban::HTMLCompiler::Context.clear_user_defined_helpers
    end
    
    def load_all
      # Load all models
      Dir.glob(File.join(Ichiban.project_root, 'models/**/*.rb')).each do |model_path|
        load_file(model_path)
      end
      
      # Load all helpers, and pass them to HTMLCompiler::Context
      Dir.glob(File.join(Ichiban.project_root, 'helpers/**/*.rb')).each do |helper_path|
        const = load_file(helper_path)
        Ichiban::HTMLCompiler::Context.add_user_defined_helper(const)
      end
    end
    
    def load_file(path)
      load path
      const_name = File.basename(path, File.extname(path)).classify
      begin
        const = Object.const_get(const_name)
      rescue NameError
        raise "Expected #{path} to define #{const_name}"
      end
      @loaded_constants << const_name.to_sym
      const
    end
  end
end