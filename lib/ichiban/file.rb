module Ichiban
  class ProjectFile
    attr_reader :abs
    
    # Returns an absolute path in the compiled directory
    def dest
      File.join(Ichiban.project_root, 'compiled', dest_rel_to_compiled)
    end
    
    # Returns a new instance based on an absolute path. Will automatically pick the right subclass.
    # Return nil if the file is not recognized.
    def self.from_abs(abs)
      rel = abs.slice(Ichiban.project_root.length..-1) # Relative to project root
      rel.sub!(/^\//, '') # Remove leading slash
      if rel.start_with?('html') and rel.end_with?('.html')
        Ichiban::HTMLFile.new(rel)
      elsif rel.start_with?('layouts') and rel.end_with?('.html')
        Ichiban::LayoutFIle.new(rel)
      elsif rel.start_with?('assets/js')
        Ichiban::JSFile.new(rel)
      elsif rel.start_with?('assets/css') and rel.end_with?('.css')
        Ichiban::CSSFile.new(rel)
      elsif rel.start_with?('assets/css') and rel.end_with?('.scss')
        Ichiban::SCSSFile.new(rel)
      elsif rel.start_with?('assets/img')
        Ichiban::ImageFile.new(rel)
      elsif rel.start_with?('assets/misc')
        Ichiban::MiscAssetFile.new(rel)
      elsif rel.start_with?('models')
        Ichiban::ModelFile.new(rel)
      elsif rel.start_with?('data')
        Ichiban::DataFile.new(rel)
      elsif rel.start_with?('scripts')
        Ichiban::ScriptFile.new(rel)
      elsif rel.start_with?('helpers')
        Ichiban::HelperFile.new(rel)
      else
        nil
      end
    end
    
    def has_dest?
      respond_to?(:dest_rel_to_compiled)
    end
    
    def initialize(rel)
      @rel = rel
      @abs = File.join(Ichiban.project_root, rel)
    end
    
    # Returns a new path where the old extension is replaced with new_ext
    def replace_ext(path, new_ext)
      path.sub(/\..+$/, '.' + new_ext)
    end
  end
  
  class HTMLFile < ProjectFile
    def dest_rel_to_compiled
      d = @rel.slice('html/'.length..-1)
      (d.end_with?('.markdown') or d.end_with?('.md')) ? replace_ext(d, 'html') : d
    end
    
    def update
      Ichiban::HTMLCompiler.new(self).compile
    end
  end
  
  class LayoutFile < ProjectFile
  end
  
  class JSFile < ProjectFile
    def dest_rel_to_compiled
      File.join('js', @rel.slice('assets/js/'.length..-1))
    end
    
    def update
      Ichiban::AssetCompiler.new(self).compile
    end
  end
  
  class CSSFile < ProjectFile
    def dest_rel_to_compiled
      File.join('css', @rel.slice('assets/css/'.length..-1))
    end
    
    def update
      Ichiban::AssetCompiler.new(self).compile
    end
  end
  
  class SCSSFile < ProjectFile
    def dest_rel_to_compiled
      replace_ext(
        File.join('css', @rel.slice('assets/css/'.length..-1)),
        'css'
      )
    end
    
    def update
      Ichiban::AssetCompiler.new(self).compile
    end
  end
  
  class ImageFile < ProjectFile
    def dest_rel_to_compiled
      File.join('img', @rel.slice('assets/img/'.length..-1))
    end
    
    def update
      Ichiban::AssetCompiler.new(self).compile
    end
  end
  
  class MiscAssetFile < ProjectFile
    def dest_rel_to_compiled
      @rel.slice('assets/misc/'.length..-1)
    end
    
    def update
      Ichiban::AssetCompiler.new(self).compile
    end
  end
  
  class ModelFile < ProjectFile
    def update
      # No-op. The watcher hands the path to each changed model file to the Loader instance.
      # So we don't have to worry about that here.
    end
  end
  
  class HelperFile < ProjectFile
    def update
      # No-op. The watcher hands the path to each changed model file to the Loader instance.
      # So we don't have to worry about that here.
    end
  end
  
  class DataFile < ProjectFile
    def update
      Ichiban.script_runner.data_file_changed(self)
    end
  end
  
  class ScriptFile < ProjectFile
    def update
      Ichiban.script_runner.script_file_changed(self)
    end
  end
end