module Ichiban
  def self.script_runner
    @script_runner ||= Ichiban::ScriptRunner.new
  end
  
  class ScriptRunner    
    # Takes an absolute path
    def script_file_changed(path)
      Ichiban.logger.script_run(path)
      script = Ichiban::Script.new(path).run
    end
  end
  
  class Script
    # Automatically appends .html to dest_path
    def generate(template_path, dest_path, ivars)
      dest_path += '.html'
      ext_to_remove = File.extname(dest_path)
      web_path = '/' + dest_path.sub(/#{ext_to_remove}$/, '') + '/'
      compiler = Ichiban::HTMLCompiler.new(
        Ichiban::HTMLFile.new(
          File.join('html', template_path)
        )
      )
      compiler.ivars = {:_current_path => web_path}.merge(ivars)
      html = compiler.compile_to_str      
      abs_dest_path = File.join(Ichiban.project_root, 'compiled', dest_path)
      FileUtils.mkdir_p File.dirname(abs_dest_path)
      File.open(abs_dest_path, 'w') do |f|
        f << html
      end
      Ichiban.logger.compilation(
        File.join(Ichiban.project_root, 'html', template_path),
        File.join(Ichiban.project_root, 'compiled', dest_path)
      )
    end
    
    # Takes an absolute path
    def initialize(path)
      @path = path
    end
    
    attr_reader :path
    
    def run
      instance_eval(
        File.read(@path),
        @path
      )
    end
  end
end