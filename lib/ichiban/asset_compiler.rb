module Ichiban
  class AssetCompiler
    def initialize(file)
      @file = file
    end
    
    def compile
      case @file
      when Ichiban::SCSSFile
        Sass.compile_file @file.abs, @file.dest
      else
        FileUtils.cp @file.abs, @file.dest
      end
      Ichiban.logger.compilation(@file.abs, @file.dest)
    end
  end
end