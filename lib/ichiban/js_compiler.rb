module Ichiban
  # This class uses source_map and uglifier to concatenate, minify, and source-map JS files.
  class JSCompiler
    def compile
      rel = @file.rel_to 'assets/js'
      Ichiban.config.js_manifests.each do |dest, sources|
        if sources.include? rel
          # Make the source paths absolute.
          sources = sources.map do |source|
            abs = File.join Ichiban.project_root, 'assets/js', source
            unless File.exists? abs
              raise "Something's wrong with Ichiban.config.js_manifests. JS source file does not exist: #{abs.inspect}"
            end
            abs
          end
          
          # Make two code strings. The first contains the minified JS. The second
          # contains the source map.
          js, map = compile_paths(
            sources,
            File.join(Ichiban.config.relative_url_root, 'js'),
            dest,
            dest + '.map'
          )
          
          # Make sure the JS folder exists.
          FileUtils.mkdir_p File.join(Ichiban.project_root, 'compiled/js')
          
          # Write the minified JS.
          compiled_js_path = File.join(Ichiban.project_root, 'compiled/js', dest)
          File.open(compiled_js_path, 'w') do |f|
            f << js
          end
          
          # Write the source map.
          File.open(File.join(Ichiban.project_root, 'compiled/js', dest + '.map'), 'w') do |f|
            f << map
          end
          
          # Log the compilation of the JS file, but don't log the compilation of the map.
          Ichiban.logger.compilation(@file.abs, compiled_js_path)
        end
      end
    end
    
    def initialize(file)
      @file = file
    end
    
    private
    
    # Pass in absolute source_paths.
    def compile_paths(source_paths, source_root, js_filename, map_filename)
      js, map = concat(
        source_paths.map { |p| [File.read(p), File.basename(p)] },
        source_root
      )
    
      js, map = uglify js, map, js_filename
      
      map_url = File.join Ichiban.config.relative_url_root, 'js', map_filename
      js << "\n//# sourceMappingURL=#{map_url}"
    
      [js, map]
    end
  
    # Sources should be an array of form: [['alert("foo");', 'alert.js']] Returns a tuple. The
    # first element is the concatenated JS. The second element is the map string.
    def concat(sources, source_root)
      js = StringIO.new
      map = SourceMap.new(
        generated_output: js,
        source_root: source_root
      )
      sources.each do |source_js, source_filename|
        map.add_generated source_js, source: source_filename
      end
      js.rewind
      [js.read, map.to_s]
    end
  
    def uglify(js, map, js_filename)
      Uglifier.new(
        input_source_map: map,
        output_filename: js_filename
      ).compile_with_map(js)
    end
  end
end