module Ichiban
  def self.script_runner
    @script_runner ||= Ichiban::ScriptRunner.new
  end
  
  class ScriptRunner
    # Takes an absolute path. Consults the dependencies graph.
    def data_file_changed(path)
      # Add one to the length to remove the leading slash
      rel_to_root = path.slice(Ichiban.project_root.length + 1..-1)
      dep_graph = Ichiban::Dependencies.graph(self.class.dep_graph_path)
      if deps = dep_graph[rel_to_root]
        deps.each do |dep|
          Ichiban.logger.script_run(path, File.join(Ichiban.project_root, dep))
          Ichiban::Script.new(
            File.join(Ichiban.project_root, dep)
          ).run
        end
      end
    end
    
    def self.dep_graph_path
      '.script_dependencies.json'
    end
    
    # Takes an absolute path
    def script_file_changed(path)
      Ichiban.logger.script_run(path, path)
      script = Ichiban::Script.new(path).run
    end
  end
  
  class Script
    # Every file that the script depends on (e.g. a data file) should be declared with this method.
    # This is how Ichiban knows to re-run the script when one of the files changes. Pass in a path
    # relative to the project root.
    #
    # However, you don't need to declare dependencies for the templates the script uses. Those will\
    # automatically be tracked.
    def depends_on(ind_path)
      if ind_path.start_with?('/')
        raise(ArgumentError, 'depends_on must be passed a path relative to the project root, e.g. "data/employees.xml"')
      end
      # Format in dependency graph: 'data/employees.json' => 'scripts/generate_employees.rb'
      Ichiban::Dependencies.update(
        Ichiban::ScriptRunner.dep_graph_path,
        
        # Path to independent file, relative to project root.
        ind_path,
        
        # Path to dependent file (i.e. this script), relative to project root.
        # Add one to the length to remove the leading slash.
        @path.slice(Ichiban.project_root.length + 1..-1)
      )
    end
    
    def generate(template_path, dest_path, ivars)
      web_path = '/' + File.basename(dest_path, File.extname(dest_path)) + '/'
      compiler = Ichiban::HTMLCompiler.new(
        Ichiban::HTMLFile.new(
          File.join('html', template_path)
        )
      )
      compiler.ivars = {:_current_path => web_path}.merge(ivars)
      html = compiler.compile_to_str
      File.open(File.join(Ichiban.project_root, 'compiled', dest_path), 'w') do |f|
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