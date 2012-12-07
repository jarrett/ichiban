module Ichiban
  class ProjectGenerator
    # The path to the empty project template in the Ichiban gem directory
    def empty_project_path
      File.expand_path(File.join(File.dirname(__FILE__), '../../empty_project'))
    end
    
    def initialize(path)
      @path = path
    end
    
    def generate
      FileUtils.cp_r(empty_project_path, @path)
    end
  end
end