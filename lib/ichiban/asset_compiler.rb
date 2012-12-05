module Ichiban
  class AssetCompiler
    def initialize(file)
      @file = file
    end
    
    def compile
      case @file
      when Ichiban::SCSSFile
        compile_scss
      else
        copy_asset
      end
    end
    
    private
    
    def compile_scss
      Sass.compile_file @file.abs, @file.dest
    end
    
    def copy_asset
      
    end
  end
end