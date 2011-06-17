module Ichiban
	class Compiler
		include Layouts
		
		def compile_all
			copy_static
		end
		
		def compile_to_file(src_path)
			src_path.create_output_dir
			File.open(src_path.to_compiled.replace_ext!('.html').abs, 'w') do |f|
				f.write compile_to_string(src_path)
			end
		end
		
		def compile_to_string(src_path)
			erb_context = ErbPage::Context.new(:_current_path => src_path.from_site_root)
			result = ErbPage.new(File.read(src_path.abs), :filename => src_path.abs).evaluate(erb_context)
			result = case src_path.ext
			when '.markdown'
				Maruku.new(result).to_html
			when '.html'
				result
			else
				raise "compile_file_to_string doesn't know how to handle #{src_path.abs}"
			end
			wrap_in_layouts(erb_context, result)
		end
		
		# Returns Path objects for all files in the content directory, regardless of extension.
		def content_files
			paths_in 'content'
		end
		
		def data_files
			paths_in 'data'
		end
		
		def error_pages
			paths_in 'errors'
		end
		
		def helpers
			paths_in 'helpers'
		end
		
		def images
			paths_in 'images'
		end
		
		def initialize(project_root)
			Ichiban.initialize(project_root)
			Ichiban.compiler = self
			@project_root = File.expand_path(project_root)
			load_ruby_files
		end
		
		def javascripts
			paths_in 'javascripts'
		end
		
		def layouts
			paths_in 'layouts'
		end
		
		def less_files
			paths_in 'stylesheets', 'less'
		end
		
		attr_reader :project_root
		
		# Loads models and helpers
		def load_ruby_files
			Dir.glob(File.join(@project_root, 'models', '**/*.rb')).each do |rb_file|
				require File.expand_path(rb_file)
			end
			Dir.glob(File.join(@project_root, 'helpers', '**/*.rb')).each do |rb_file|
				require File.expand_path(rb_file)
				module_name = File.basename(rb_file, '.rb').classify
				begin
					mod = Object.const_get(module_name)
				rescue NameError
					raise "Expected #{rb_file} to define #{module_name}"
				end
				ErbPage::Context.send(:include, mod)
			end
		end
		
		def models
			paths_in 'models'
		end
		
		def scss_files
			paths_in 'stylesheets', 'scss'
		end
		
		def stylesheets
			paths_in 'stylesheets', 'css'
		end
		
		private
		
		def paths_in(dir, ext = nil)
			pattern = ext ? "**/*.#{ext}" : '**/*'
			Dir.glob(File.join(@project_root, dir, pattern)).collect { |abs| Path.new abs }
		end
	end
end