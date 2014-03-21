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
      add_preamble(
        EJS.compile(
          File.read(@ejs_file.abs)
        ),
        File.basename(@ejs_file.dest, '.ejs')
      )
    end
  
    def initialize(ejs_file)
      @ejs_file = ejs_file
    end
    
    private
    
    def add_preamble(fn, name)
      %Q(if (typeof(window.EJS) == "undefined") { window.EJS = {} } ) +
      %Q(window.EJS[#{JSON.dump(name)}] = #{fn})
    end
  end
end