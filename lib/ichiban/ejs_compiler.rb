module Ichiban
  class EJSCompiler
    def compile
      FileUtils.mkdir_p File.dirname(@ejs_file.dest)
      File.open(@ejs_file.dest, 'w') do |f|
        f << compile_to_str
      end
      Ichiban.logger.compilation(@ejs_file.abs, @ejs_file.dest)
    end
  
    def compile_to_str
      EJS.compile File.read(@ejs_file.abs)
    end
  
    def initialize(ejs_file)
      @ejs_file = ejs_file
    end
  end
end