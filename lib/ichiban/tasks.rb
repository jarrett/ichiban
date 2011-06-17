# Put this in a Rakefile:
# 
#   require 'ichiban'
#   Ichiban::Tasks.new.define

module Ichiban
	class Tasks
		def compile(clean)
			Ichiban.compile(File.expand_path(File.dirname(__FILE__))) do |compiler|
				compile_with(clean, compiler)
			end
		end
		
		def compile_less(compiler, less_path, css_path)
			if Ichiban.config.use_less_gem
				Less::Command.new(:source => less_path.abs, :destination => css_path.abs).run!
			else
				File.open(css_path.abs, 'w') do |f|
					Dir.chdir(File.join(compiler.project_root, 'stylesheets')) do
						f.write `node ../less.js #{less_path.abs}`
					end
				end
			end
		end
		
		def compile_scss(compiler, scss_path, css_path)
			Sass.compile_file(scss_path.abs, css_path.abs)
		end
		
		def compile_with(clean, compiler)
			@logged_compilations = []
			universal_dependencies = (compiler.layouts + compiler.helpers + compiler.models + compiler.data_files).collect(&:abs)
			(compiler.content_files + compiler.error_pages).each do |src_path|
				if Ichiban::PAGE_FILE_EXTENSIONS.include?(src_path.ext)
					if clean or !uptodate?(src_path.to_compiled.abs, universal_dependencies + [src_path.abs])
						compiler.compile_to_file(src_path)
						log_compilation(src_path, src_path.to_compiled)
					end
				elsif !File.directory?(src_path.abs) and (clean or !uptodate?(src_path.to_compiled.abs, src_path.abs))
					src_path.copy_out
					log_compilation(src_path, src_path.to_compiled)
				end
			end
			compiler.scss_files.each do |scss_path|
				css_path = Ichiban::Path.new(scss_path.to_compiled.abs.sub(/\.scss$/, '.css'))
				if !Ichiban.config.ignored_scss_files.include?(scss_path.base) and (clean or !uptodate?(css_path.abs, scss_path.abs))
					compile_scss(compiler, scss_path, css_path)
					log_compilation scss_path, css_path
				end
			end
			#compiler.less_files.each do |less_path|
			#	css_path = Ichiban::Path.new(less_path.to_compiled.abs.sub(/\.less$/, '.css'))
			#	if !Ichiban.config.ignored_less_files.include?(less_path.base) and (clean or !uptodate?(css_path.abs, less_path.abs))
			#		compile_less(compiler, less_path, css_path)
			#		log_compilation less_path, css_path
			#	end
			#end
			(compiler.images + compiler.javascripts + compiler.stylesheets + [::Ichiban::Path.new('htaccess.txt', :project)]).each do |path|
				if clean or !uptodate?(path.to_compiled.abs, path.abs)
					path.copy_out
					log_compilation path, path.to_compiled
				end
			end
			print_logged_compilations
		end
		
		def define		
			desc 'Generates the static site and puts it in the "compiled" directory. Files will only be compiled as necessary. If a layout has been modified, all files will be recompiled.'
			task :compile do
				compile(false)
			end
			
			task :default => :compile
			
			desc 'Generates the static site and puts it in the "compiled" directory. All files will be compiled from scratch.'
			task :recompile do
				compile(true)
			end
			
			task :watch do
				watch
			end
		end
		
		def log_compilation(src, dest)
			raise "Expected Path but got #{src.inspect}" unless src.is_a?(Ichiban::Path)
			raise "Expected Path but got #{dest.inspect}" unless dest.is_a?(Ichiban::Path)
			@logged_compilations << [src, dest]
		end
		
		def print_logged_compilations
			max_width = @logged_compilations.inject(0) do |max, (src, dest)|
				src.from_project_root.length > max ? src.from_project_root.length : max
			end
			@logged_compilations.each do |src, dest|
				puts "#{src.from_project_root.ljust(max_width)}   =>   #{dest.from_project_root}"
			end
		end
		
		def rescue_interrupt
			begin
				yield
			rescue Interrupt
				puts
				exit 0
			end
		end
		
		def watch
			Ichiban.compile(File.expand_path(File.dirname(__FILE__))) do |compiler|
				@last_compile = Time.now
				loop do
					rescue_interrupt { sleep 1 }
					
					# This is a faster way to check for changes than to run compile(false) every time.
					src_files = Dir.glob(File.join(compiler.project_root, '**/*'))
					if src_files.any? { |src| File.stat(src).mtime >= @last_compile }
						@last_compile = Time.now
						puts Time.now.strftime("%H:%M:%S -- Possible change detected. Compiling any files that need it.")
						rescue_interrupt do
							begin
								compile_with(false, compiler)
							rescue Exception => exc
								puts exc.message + "\n" + exc.backtrace.join("\n")
							end
						end
					end
				end
			end
		end
	end
end
