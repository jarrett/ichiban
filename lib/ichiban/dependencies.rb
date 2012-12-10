module Ichiban
  module Dependencies
    @graphs = {}
    
    # Does not delete the files. Just clears the graphs from memory. This gets called whenever
    # Ichiban.project_root is changed.
    def self.clear_graphs
      @graphs = {}
    end
    
    # graph_file_path is a relative path
    def self.graph(graph_file_path)
      ensure_graph_initialized(graph_file_path)
      @graphs[graph_file_path]
    end
    
    # graph_file_path is a relative path
    def self.ensure_graph_initialized(graph_file_path)
      unless @graphs[graph_file_path]
        abs = File.join(Ichiban.project_root, graph_file_path)
        if File.exists?(abs)
          @graphs[graph_file_path] = JSON.parse(File.read(abs))
        else
          @graphs[graph_file_path] = {}
        end
      end
    end
    
    # Loads the graph from disk if it's not already in memory. Updates the graph. Writes the new
    # graph to disk. graph_file_path is a relative path.
    def self.update(graph_file_path, ind, dep)
      ensure_graph_initialized(graph_file_path)
      graph = @graphs[graph_file_path]
      graph[ind] ||= []
      graph[ind] << dep unless graph[ind].include?(dep)
      File.open(File.join(Ichiban.project_root, graph_file_path), 'w') do |f|
        f << JSON.generate(graph)
      end
    end
  end
end