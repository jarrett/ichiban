module Ichiban
  class File
    attr_reader :abs
    
    # Returns an absolute path in the compiled directory
    def dest
      ::File.join(Ichiban.project_root, 'compiled', dest_rel_to_compiled)
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
    
    def initialize(rel)
      @rel = rel
      @abs = ::File.join(Ichiban.project_root, rel)
    end
    
    # Returns a new path where the old extension is replaced with new_ext
    def replace_ext(path, new_ext)
      path.sub(/\..+$/, '.' + new_ext)
    end
  end
  
  class HTMLFile < File
    def dest_rel_to_compiled
      d = @rel.slice('html/'.length..-1)
      (d.end_with?('.markdown') or d.end_with?('.md')) ? replace_ext(d, 'html') : d
    end
    
    def update
      Ichiban::HTMLCompiler.new.compile(self)
    end
  end
  
  class LayoutFile < File
  end
  
  class JSFile < File
    def dest_rel_to_compiled
      File.join('js', @rel.slice('assets/js/'.length..-1))
    end
  end
  
  class CSSFile < File
    def dest_rel_to_compiled
      File.join('css', @rel.slice('assets/css/'.length..-1))
    end
  end
  
  class SCSSFile < File
    def dest_rel_to_compiled
      replace_ext(
        File.join('css', @rel.slice('assets/css/'.length..-1)),
        'css'
      )
    end
  end
  
  class ImageFile < File
    def dest_rel_to_compiled
      File.join('img', @rel.slice('assets/img/'.length..-1))
    end
  end
  
  class MiscAssetFile < File
    def dest_rel_to_compiled
      @rel.slice('assets/misc/'.length..-1)
    end
  end
  
  class ModelFile < File
  end
  
  class DataFile < File
  end
  
  class ScriptFile < File
  end
  
  class HelperFile < File
  end
end