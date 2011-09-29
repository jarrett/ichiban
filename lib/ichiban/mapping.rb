module Ichiban
	class Compiler
		def content_dest(src_path)
			if src_path.ext == 'markdown'
				src_path = src_path.replace_ext('html')
			end
			Path.new(
				File.join(Ichiban.project_root, 'compiled',
					src_path.relative_from('content')
				)
			)
		end
		
		def image_dest(src_path)
			Path.new(
				File.join(Ichiban.project_root, 'compiled', 'images',
					src_path.relative_from('images')
				)
			)
		end
		
		def javascript_dest(src_path)
			Path.new(
				File.join(Ichiban.project_root, 'compiled', 'javascripts',
					src_path.relative_from('javascripts')
				)
			)
		end
		
		def stylesheet_dest(src_path)
			Path.new(
				File.join(Ichiban.project_root, 'compiled', 'stylesheets',
					src_path.relative_from('stylesheets')
				)
			).replace_ext('css')
		end
	end
end