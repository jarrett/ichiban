module Ichiban
  # This class uses the UglifyJS2 binary (uglifyjs) to concatenate and minify JS source
  # files. You must have uglify-js on your path.
  class JSCompiler
    def compile
      rel = @file.rel_to 'assets/js'
      Ichiban.config.js_manifests.each do |dest, sources|
        if sources.include? rel
          # Before doing anything, we compute several paths. Assume, for the sake of
          # example, that dest == 'foo/bar.js'. Then the paths would be:
          # 
          # Variable                Example value
          # ------------------------------------------------------------------------------
          # dest                    foo/bar.js
          # dest_folder             /home/johnq/mysite/compiled/js/foo
          # ugly_js_path            /home/johnq/mysite/compiled/js/foo/bar.js
          # map_path                /home/johnq/mysite/compiled/js/foo/bar.js.map
          # map_path_from_webroot   /js/foo/bar.js.map
          
          dest_folder = File.expand_path(File.join(
            Ichiban.project_root, 'compiled', 'js',
            File.dirname(dest)
          ))
          
          ugly_js_path = File.join(Ichiban.project_root, 'compiled', 'js', dest)
          
          map_path = ugly_js_path + '.map'
          
          map_path_from_webroot = File.join('/js', dest + '.map')
          
          # Make individual, uglified JS and maps.
          compiled = sources.map do |src_path|
            src_js = File.read File.join(Ichiban.project_root, 'assets', 'js', src_path)
            ugly_js, map_json = Uglifier.compile_with_map src_js, source_map: {filename: src_path}
            [
              ugly_js,
              SourceMap::Map.from_json(map_json)
            ]
          end
          
          # Concatenate the uglified JS and maps.
          all_js, all_maps = compiled.inject do |(all_js, all_maps), (this_js, this_map)|
            # all_js and this_js are strings. all_maps and this_map are instances of
            # SourceMap::Map. (SourceMap::Map supports the + operator.)
            [all_js + this_js, all_maps + this_map]
          end
          
          # Ensure the destination folder exists.
          unless File.exist? dest_folder
            FileUtils.mkdir_p dest_folder
          end
          
          # Write the compiled JS.
          File.open(ugly_js_path, 'w') do |f|
            f << all_js << "\n//# sourceMappingURL=#{map_path_from_webroot}"
          end
          
          # Write the map.
          File.open(map_path, 'w') do |f|
            f << all_maps.to_json
          end
          
          # Copy each source file (for the sake of mapping).
          sources.each do |src_path|
            FileUtils.cp(
              File.join(Ichiban.project_root, 'assets/js', src_path),
              File.join(Ichiban.project_root, 'compiled/js', src_path),
            )
          end
          
          # Log the compilation of the JS file, but don't log the compilation of the map.
          Ichiban.logger.compilation(@file.abs, dest)
        end
      end
    end
    
    def initialize(file)
      @file = file
    end
  end
  
  class UglifyError < RuntimeError; end
end