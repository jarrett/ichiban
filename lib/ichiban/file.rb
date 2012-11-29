module Ichiban
  class File
    # Returns a new instance based on an absolute path. Will automatically pick the right subclass.
    def self.from_abs(abs)
      rel = abs.slice(Ichiban.project_root.length..-1) # Relative to project root
      rel.sub!(/^\//, '') # Remove leading slash
      if rel.start_with?('content')
        Ichiban::ContentFile.new(rel)
      elsif rel.start_with?('assets/js')
        Ichiban::JSFile.new(rel)
      elsif rel.start_with?('assets/css') and rel.end_with?('.scss')
        Ichiban::SCSSFile.new(rel)
      elsif rel.start_with?('assets/img')
        Ichiban::ImageFile.new(rel)
      elsif rel.start_with?('misc')
        Ichiban::MiscAssetFile.new(rel)
      end
    end
    
    def initialize(re;)
      @rel = rel
      @abs = File.join(Ichiban.project_root, rel)
    end
    
    # Returns a new path where the old extension is replaced with new_ext
    def replace_ext(path, new_ext)
      path.sub(/\..+$/, '.' + new_ext)
    end
  end
  
  class ContentFile < File
    # Returns an absolute path in the compiled directory
    def dest
      compiled_path = rel.slice('content/'.length..-1)
      if compiled_path.end_with?('.markdown')
        compiled_path = replace_ext(compiled_path, '.html')
      end
      File.join(project_root, 'compiled', compiled_path)
    end
  end
end