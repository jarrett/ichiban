module Ichiban
  class ManualCompiler
    def all
      paths(
        Dir.glob(File.join(Ichiban.project_root, 'html',      '**', '*')) +
        Dir.glob(File.join(Ichiban.project_root, 'assets',    '**', '*')) +
        Dir.glob(File.join(Ichiban.project_root, 'scripts',   '**', '*')) +
        Dir.glob(File.join(Ichiban.project_root, 'webserver', '**', '*'))
      )
    end
    
    def paths(paths_to_compile)
      Ichiban::Loader.new
      paths_to_compile.each do |path|
        unless path.start_with? Ichiban.project_root
          path = File.join(Ichiban.project_root, path)
        end
        begin
          if project_file = Ichiban::ProjectFile.from_abs(path)
            project_file.update
          end
        rescue Exception => exc
          Ichiban.logger.exception(exc)
        end
      end
    end
  end
end