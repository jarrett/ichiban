module Ichiban
	# This class runs .rb files located in the content folder. Its main purpose is to generate pages from databases.
	class ScriptRunner
		include Layouts
		
		def generate(template_path_from_content_root, destination_path_from_site_root, ivars)
			template_path = Path.new(
				File.join(Ichiban.project_root, 'content', template_path_from_content_root)
			)
			destination_path = Path.new(
				File.join(Ichiban.project_root, 'compiled', destination_path_from_site_root + '.html')
			)
			erb_context = ErbPage::Context.new(ivars.merge(:_current_path => destination_path_from_site_root))
			result = ErbPage.new(File.read(template_path.abs), :filename => template_path.abs).evaluate(erb_context)
			result = wrap_in_layouts(erb_context, result)
			File.open(destination_path.abs, 'w') do |f|
				f.write result
			end
		end
		
		def initialize(path)
			@source = path.abs
		end
		
		def self.run_script_file(path)
			new(path).run
		end
		
		def run
			instance_eval(File.read(@source), @source)
		end
	end
end