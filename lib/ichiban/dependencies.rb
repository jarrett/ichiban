module Ichiban
  module Dependencies
    @graphs = {}
    
    # graph_file_path is an absolute path.
    def self.graph(graph_file_path)
      ensure_graph_initialized(graph_file_path)
      @graphs[graph_file_path]
    end
    
    def self.ensure_graph_initialized(graph_file_path)
      unless @graphs[graph_file_path]
        if ::File.exists?(graph_file_path)
          @graphs[graph_file_path] = JSON.parse(::File.read(graph_file_path))
        else
          @graphs[graph_file_path] = {}
        end
      end
    end
    
    # Loads the graph from disk if it's not already in memory. Updates the graph. Writes the new
    # graph to disk. graph_file_path is an absolute path.
    def self.update(graph_file_path, ind, dep)
      ensure_graph_initialized(graph_file_path)
      graph = @graphs[graph_file_path]
      graph[ind] ||= []
      graph[ind] << dep unless graph[ind].include?(dep)
      ::File.open(graph_file_path, 'w') do |f|
        f << JSON.generate(graph)
      end
    end
  end
end