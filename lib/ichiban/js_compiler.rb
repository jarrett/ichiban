module Ichiban
  # This class uses the UglifyJS2 binary to concatenate and minify JS source files.
  class JSCompiler
    def compile
      rel = @file.rel_to 'assets/js'
      Ichiban.config.js_manifests.each do |dest, sources|
        if sources.include? rel
          # Make the destination folder if necessary.
          dest_folder = File.expand_path(File.join(
            Ichiban.project_root, 'compiled', 'js',
            File.dirname(dest)
          ))
          unless File.exists? dest_folder
            FileUtils.mkdir_p dest_folder
          end
          
          # Build the name of the source map.
          map_name = File.basename(dest, File.extname(dest)) + '.js.map'
          
          # Shell out to UglifyJS2.
          uglify_stdout = `
            cd #{File.join(Ichiban.project_root, 'assets', 'js')} && \
            uglifyjs \
              #{sources.join(' ')} \
              --output #{File.join(Ichiban.project_root, 'compiled', 'js', dest)} \
              --source-map #{map_name} \
              --source-map-url /js/#{map_name} \
              --source-map-root /js \
            2>&1 # Redirect STDERR to STDOUT.
          `
          unless $?.success?
            raise UglifyError, "uglifyjs command failed:\n\n#{uglify_stdout}"
          end
          
          # Uglify populates the source map's "file" property with the absolute path.
          # Replace it with the filename.
          map_path = File.join Ichiban.project_root, 'assets', 'js', map_name
          map_json = JSON.parse(File.read(map_path))
          File.open map_path, 'w' do |f|
            f << JSON.dump(map_json.merge('file' => dest))
          end
          
          # Uglify writes the source map in assets/js.
          # Move it into compiled/js.
          FileUtils.mv(
            File.join(Ichiban.project_root, 'assets', 'js', map_name),
            File.join(Ichiban.project_root, 'compiled', 'js')
          )
          
          # Copy each of the source files into compiled/js so that JS debuggers
          # can use them with the source map.
          sources.each do |filename|
            folder = File.expand_path(File.join(
              Ichiban.project_root, 'compiled', 'js',
              File.dirname(filename)
            ))
            unless File.exists? folder
              FileUtils.mkdir_p folder
            end
            FileUtils.cp(
              File.join(Ichiban.project_root, 'assets', 'js', filename),
              File.join(Ichiban.project_root, 'compiled', 'js')
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
    
    private
    
    # Pass in absolute source_paths.
    #def compile_paths(source_paths, source_root, js_filename, map_filename)
    #  # The Uglify gem, unlike UglifyJS2, doesn't support concatenation as of August 2015.
    #  # Thus, before we call Uglify, we have to concatenate ourselves. We also generate an
    #  # intermediate source map for the concatenated JS. Uglify will use the intermediate
    #  # source map when it creates its own source map.
    #  js, map = concat(
    #    source_paths.map { |p| [File.read(p), File.basename(p)] },
    #    source_root
    #  )
    #
    #  js, map = uglify js, map, js_filename
    #  
    #  map_url = File.join Ichiban.config.relative_url_root, 'js', map_filename
    #  js << "\n//# sourceMappingURL=#{map_url}"
    #
    #  [js, map]
    #end
  
    # Sources should be an array of form: [['alert("foo");', 'alert.js']] Returns a tuple. The
    # first element is the concatenated JS. The second element is the map string.
    #def concat(sources, source_root)
    #  js = StringIO.new
    #  map = SourceMap.new(
    #    generated_output: js,
    #    source_root: source_root
    #  )
    #  sources.each do |source_js, source_filename|
    #    map.add_generated source_js, source: File.join(source_filename)
    #  end
    #  js.rewind
    #  puts map.to_s
    #  [js.read, map.to_s]
    #end
  
    #def uglify(js, map, js_filename)
    #  Uglifier.new(
    #    input_source_map: map,
    #   output_filename: js_filename
    # ).compile_with_map(js)
    #end
  end
  
  class UglifyError < RuntimeError; end
end