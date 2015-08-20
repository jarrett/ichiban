module Ichiban
  class ProjectFile
    @types = []
    
    attr_reader :abs
    
    # Returns an absolute path in the compiled directory
    def dest
      File.join(Ichiban.project_root, 'compiled', dest_rel_to_compiled)
    end
    
    # Returns a new instance based on an absolute path. Will automatically pick the right subclass.
    # Return nil if the file is not recognized.
    def self.from_abs(abs)
      return nil if File.directory?(abs)
      rel = abs.slice(Ichiban.project_root.length..-1) # Relative to project root
      rel.sub!(/^\//, '') # Remove leading slash
      handler = @types.detect do |_, proc|
        proc.call rel
      end
      if handler
        klass = handler.first
        klass.new rel
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
    
    # Pass in a subclass of Ichiban::ProjectFile and a block. The block accepts one param:
    # a file path relative to the Ichiban project root. For example: 'assets/css/main.css'.
    # Each time the watcher detects a change to a file, the file's path will be passed to
    # the block. If the block returns true, an instance of klass will be created to compile
    # the changed file.
    def self.register_type(klass, &block)
      @types << [klass, block]
    end
    
    attr_reader :rel
    
    # Pass in a path relative to Ichiban.projet_root. Returns the path relative to the
    # one you passed in. E.g. if the file is assets/js/example.js, then
    # rel_to('assets/js') returns 'example.js'.
    def rel_to(path)
      path = path + '/' unless path.end_with?('/')
      if rel.start_with?(path)
        rel.sub(path, '')
      else
        raise "#{@abs} is not in #{path}"
      end
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
    
    def web_path
      d = dest_rel_to_compiled
      fname = File.basename(d, File.extname(d))
      if fname == 'index'
        # If this is an index file, the web path is just the folder name.
        '/' + File.dirname(d) + '/'
      else
        p = '/' + File.join(File.dirname(d), fname) + '/'
        p.sub!('/./', '/') if p.start_with?('/./')
        p
      end
    end
  end
  
  class PartialHTMLFile < ProjectFile
    # Returns something like 'foo/bar'
    def partial_name
      File.basename(
        @abs.slice(Ichiban.project_root.length + 1..-1),
        File.extname(@abs)
      )
    end
    
    def update
      # no-op
    end
  end
  
  class LayoutFile < ProjectFile
    def layout_name
      File.basename(@abs, File.extname(@abs))
    end
    
    def update
      # no-op
    end
  end
  
  class JSFile < ProjectFile    
    def update
      Ichiban::JSCompiler.new(self).compile
    end
  end
  
  class EJSFile < ProjectFile
    def dest_rel_to_compiled
      File.join('ejs', File.basename(@rel, '.ejs') + '.js')
    end
    
    def update
      Ichiban::EJSCompiler.new(self).compile
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
      if Ichiban.config.scss_root_files.include?(rel_to('assets/css'))
        Ichiban::AssetCompiler.new(self).compile
      end
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
  
  class HtaccessFile < ProjectFile
    def dest_rel_to_compiled
      '.htaccess'
    end
    
    def update
      Ichiban::AssetCompiler.new(self).compile
    end
  end
  
  class ModelFile < ProjectFile
    def update
      # No-op. The watcher hands the path to every changed file to the Loader instance.
      # So we don't have to worry about that here.
    end
  end
  
  class HelperFile < ProjectFile
    def update
      # No-op. The watcher hands the path to every changed file to the Loader instance.
      # So we don't have to worry about that here.
    end
  end
  
  class DataFile < ProjectFile
    def update
      #no-op
    end
  end
  
  class ScriptFile < ProjectFile
    def update
      Ichiban.script_runner.script_file_changed(@abs)
    end
  end
  
  # Re-open this class to register all default file types
  class ProjectFile
    register_type(Ichiban::PartialHTMLFile) do |rel|
      rel.start_with?('html') and
      (rel.end_with?('.html') or rel.end_with?('.md') or rel.end_with?('.markdown')) and
      File.basename(rel).start_with?('_')
    end
    register_type(Ichiban::HTMLFile) do |rel|
      rel.start_with?('html') and
      (rel.end_with?('.html') or rel.end_with?('.md') or rel.end_with?('.markdown')) and
      !File.basename(rel).start_with?('_')
    end
    register_type(Ichiban::LayoutFile)    { |rel| rel.start_with?('layouts') and rel.end_with?('.html') }
    register_type(Ichiban::JSFile)        { |rel| rel.start_with?('assets/js') and rel.end_with?('.js') }
    register_type(Ichiban::EJSFile)       { |rel| rel.start_with?('assets/ejs') and rel.end_with?('.ejs') }
    register_type(Ichiban::CSSFile)       { |rel| rel.start_with?('assets/css') and rel.end_with?('.css') }
    register_type(Ichiban::SCSSFile)      { |rel| rel.start_with?('assets/css') and rel.end_with?('.scss') }
    register_type(Ichiban::ImageFile)     { |rel| rel.start_with?('assets/img') }
    register_type(Ichiban::MiscAssetFile) { |rel| rel.start_with?('assets/misc') }
    register_type(Ichiban::ModelFile)     { |rel| rel.start_with?('models') and rel.end_with?('.rb') }
    register_type(Ichiban::DataFile)      { |rel| rel.start_with?('data') }
    register_type(Ichiban::ScriptFile)    { |rel| rel.start_with?('scripts') and rel.end_with?('.rb') }
    register_type(Ichiban::HelperFile)    { |rel| rel.start_with?('helpers') and rel.end_with?('.rb') }
    register_type(Ichiban::HtaccessFile)  { |rel| rel == 'webserver/htaccess.txt' }
  end
end