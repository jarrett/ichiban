module Ichiban
  class AssetCompiler
    def initialize(file)
      @file = file
    end
    
    def compile
      dir = File.dirname @file.dest
      unless File.directory? dir
        FileUtils.mkdir_p dir
      end
      case @file
      when Ichiban::SCSSFile
        Sass.compile_file @file.abs, @file.dest, load_paths: [File.join(Ichiban.project_root, 'assets/css')]
      else
        FileUtils.cp @file.abs, @file.dest
      end
      Ichiban.logger.compilation(@file.abs, @file.dest)
    end
  end
end