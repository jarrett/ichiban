module Ichiban
  module Dependencies   
    def self.files_depending_on(abs_path)
      rel = abs_path.slice((Ichiban.project_root.length + 1)..-1)
      if deps = Ichiban.config.dependencies[rel]
        case deps
        when String
          paths = Dir.glob(File.join(Ichiban.project_root, deps))
        when Array
          paths = deps.map do |dep|
            case dep
            when String
              Dir.glob(File.join(Ichiban.project_root, dep))
            when Proc
              files_from_proc(dep)
            else
              raise(TypeError, "Expected String or Proc, but was: #{files.inspect}")
            end
          end.flatten
        when Proc
          paths = [files_from_proc(deps)].flatten
        else
          raise(TypeError, "Expected String, Array, or Proc, but was: #{files.inspect}")
        end
        paths.map do |path|
          project_file = Ichiban::ProjectFile.from_abs(path)
        end.compact
      else
        []
      end
    end
    
    def self.files_from_proc(proc)
      files = proc.call
      # Validate return value is String or Array.
      if !files.is_a?(String) and !files.is_a?(Array)
        raise(TypeError, "Expected Proc to return String or Array, but was: #{files.inspect}")
      end
      # If return value is Array, validate all members are Strings.
      if files.is_a?(Array) and !files.all? { |f| f.is_a?(String) }
        raise(TypeError, "Proc returned Array, but not all elements were Strings: #{files.inspect}")
      end
      # If return value is String, wrap it in an Array.
      if files.is_a?(String)
        files = [files]
      end
      files.map do |file|
        File.join(Ichiban.project_root,file)
      end
    end
    
    def self.propagate(path)
      files_depending_on(path).each do |project_file|
        project_file.update
      end
    end
  end
end