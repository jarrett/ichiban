=begin
- Content file
- Stylesheet
- JS
- Image

...do each of these:

- Compile/copy one
- List all
- List stale
- Compile/copy all
- Compile/copy stale
=end

module Ichiban
	class Compiler		
		def content_files
			paths_in('content').reject { |path| path.directory? }
		end
		
		def data_files
			paths_in 'data'
		end
		
		def helpers
			paths_in 'helpers', 'rb'
		end
		
		def images
			paths_in 'images'
		end
		
		def models
			paths_in 'models', 'rb'
		end
		
		# Returns all stylesheet except for those beginning with an underscore
		def stylesheets
			paths_in('stylesheets').reject { |path| path.filename.start_with?('_') }
		end
		
		def javascripts
			paths_in 'javascripts', 'js'
		end
		
		def scripts
			paths_in 'scripts', 'rb'
		end
		
		# For the stale methods, we rely on the source-destination mapping as provided by mapping.rb.
		
		def stale_content_files
			stale(content_files) do |src_path|
				content_dest(src_path)
			end
		end
		
		def stale_images
			stale(images) do |src_path|
				image_dest(src_path)
			end
		end
		
		def stale_stylesheets
			stale(stylesheets) do |src_path|
				stylesheet_dest(src_path)
			end
		end
		
		def stale_javascripts
			stale(javascripts) do |src_path|
				javascript_dest(src_path)
			end
		end
		
		private
		
		def paths_in(dir, ext = nil)
			pattern = ext ? "**/*.#{ext}" : '**/*'
			Dir.glob(File.join(Ichiban.project_root, dir, pattern)).collect { |abs| Path.new abs }
		end
		
		# This method accepts a block. The block will be passed a source file path and must return either a destination path or an array thereof.
		def stale(source_paths)
			source_paths.reject do |path|
				dest = yield(path)
				dest = [dest] unless dest.is_a?(Array)
				up_to_date?(path, *dest)
			end
		end
		
		# Accepts one source file and one or more destination files. Pass in Path objects.
		# Note that this method is different from the one in FileUtils: The FileUtils version accepts
		# one destination and multiple sources.
		def up_to_date?(src, *dests)
			src_time = File.mtime(src.abs)
			dests.each do |dest|
				return false if !File.exists?(dest.abs)
				return false unless File.mtime(dest.abs) > src_time
			end
			true
		end
	end
end