module Ichiban
  module Dependencies   
    def self.files_depending_on(path)
      rel = path.slice(Ichiban.project_root.length..-1)
      if deps = Ichiban.config.dependencies[rel]
        case deps
        when String
          paths = Dir.glob(File.join(Ichiban.project_root, deps))
        when Array
          paths = deps.map do |dep|
            case dep
            when String
              Dir.glob(File.join(Ichiban.project_root, deps))
            when Proc
              files_from_proc(dep)
            else
              raise("Expected String or Proc, but was: #{files.inspect}")
            end
          end.flatten
        when Proc
          paths = [files_from_proc(deps)].flatten
        else
          raise("Expected String, Array, or Proc, but was: #{files.inspect}")
        end
        paths.map do |path|
          Ichiban::ProjectFile.from_abs(File.join(Ichiban.project_root, path))
        end
      else
        []
      end
    end
    
    def self.files_from_proc(proc)
      files = proc.call
      if !files.is_a?(String) and !files.is_a?(Array)
        raise("Expected Proc to return String or Array, but was: #{files.inspect}"
      end
      if files.is_a?(Array) and !files.all? { |f| f.is_a?(String) }
        raise("Proc returned Array, but not all elements were Strings: #{files.inspect}")
      end
      files
    end
    
    def self.propagate(path)
      files_depending_on(path).each do |project_file|
        project_file.update
      end
    end
  end
end