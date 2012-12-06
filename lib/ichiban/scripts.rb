module Ichiban
  def self.script_runner
    @script_runner ||= Ichiban::ScriptRunner.new
  end
  
  class ScriptRunner
    # Go through all our scripts. If any of them depends on this data file, run it again.
    def data_file_changed(file)
      @scripts.each do |script|
        if script.depends_on?(file.abs)
          script.run
        end
      end
    end
    
    def initialize
      @scripts = []
    end
    
    def script_file_changed(file)
      # Find the script in our list of scripts. If it's not there, add it.
      script = @scripts.detect { |s| s.path == file.abs }
      if script.nil?
        script = Ichiban::Script.new(file.abs)
        @scripts << script
      end
      script.run
    end
  end
  
  class Script
    # Every file that the script depends on (e.g. a data file) should be declared with this method.
    # This is how Ichiban knows to re-run the script when one of the files changes. Pass in a path
    # relative to the project root.
    def depends_on(ind_path)
      ind_path = File.join(Ichiban.project_root, ind_path)
      Ichiban::Dependencies.update(dep_graph_path, ind_path, @path)
    end
    
    def depends_on?(path)
      Ichiban::Dependencies.graph(dep_graph_path)
    end
    
    def dep_graph_path
      File.join(Ichiban.project_root, '.script_dependencies.json')
    end
    
    def generate(template_path, dest_path, ivars)
      compiler = Ichiban::HTMLCompiler.new(nil) # No HTMLFile to be passed in
      compiler.ivars = {:_current_path => dest_path}.merge(ivars)
      html = compiler.compile_to_str
      File.open(File.join(Ichiban.project_root, 'compiled', dest_path), 'w') do |f|
        f << html
      end
      Ichiban.logger.compilation(template_path, dest_path)
    end
    
    def initialize(path)
      @path = path
    end
    
    attr_reader :path
    
    def run
      instance_eval(
        File.read(@path)
      )
    end
  end
end