module Ichiban
	class Compiler
		include Layouts
		
		# This should not be called from the watcher. The watcher should have a more fine-grained way of looking at changed files.
		def compile
			load_all_ruby_files
			compile_stale
			run_scripts
		end
		
		# Includes, content, images, etc
		def compile_all
			content_files.each { |path| compile_content_file(path) }
			javascripts.each { |path| copy_javascript(path) }
			images.each { |path| copy_image(path) }
			stylesheets.each { |path| copy_or_compile_stylesheet(path) }
		end
		
		def compile_content_file(src_path)
			dest_path = content_dest(src_path)
			FileUtils.mkdir_p File.dirname(dest_path.abs)
			File.open(dest_path.replace_ext('html').abs, 'w') do |f|
			  begin
  				f.write(compile_content_file_to_string(src_path))
  			rescue Exception => exc
  			  Ichiban.logger.error("#{exc.class.to_s}: #{exc.message}\n" + exc.backtrace.collect { |line| '  ' + line }.join("\n"))
  			end
			end
		end
		
		def compile_content_file_to_string(src_path)
			erb_context = ErbPage::Context.new(:_current_path => content_dest(src_path).web)
			result = ErbPage.new(File.read(src_path.abs), :filename => src_path.abs).evaluate(erb_context)
			result = case src_path.ext
			when 'markdown'
				Maruku.new(result).to_html
			when 'html'
				result
			else
				raise "compile_file_to_string doesn't know how to handle #{src_path.abs}"
			end
			wrap_in_layouts(erb_context, result)
		end
		
		# Includes, content, images, etc
		def compile_stale
			stale_content_files.each { |path| compile_content_file(path) }
			stale_javascripts.each { |path| copy_js(path) }
			stale_images.each { |path| copy_image(path) }
			stale_stylesheets.each { |path| copy_or_compile_stylesheet(path) }
		end
		
		def copy_image(path)
			dest = image_dest(path)
			FileUtils.mkdir_p(dest.dirname)
			FileUtils.cp(path.abs, dest.abs)
		end
		
		def copy_javascript(path)
			dest = javascript_dest(path)
			FileUtils.mkdir_p(dest.dirname)
			FileUtils.cp(path.abs, dest.abs)
		end
		
		def copy_or_compile_stylesheet(path)
			dest = stylesheet_dest(path)
			case path.ext
			when 'css'
				FileUtils.mkdir_p(dest.dirname)
				FileUtils.cp(path.abs, dest.abs)
			when 'scss', 'sass'
				Sass.compile_file(path.abs, dest.abs, :style => :compressed)
			end
		end
		
		def fresh
			load_all_ruby_files
			compile_all
			run_scripts
		end
		
		def run_scripts
			scripts.each do |path|
				ScriptRunner.run_script_file(path)
			end
		end
	end
end