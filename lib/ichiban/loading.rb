module Ichiban
	class Compiler
		def load_all_ruby_files
			models.each { |path| load path.abs }
			helpers.each { |path| load_helper path }
		end
		
		def load_helper(path)
			load path.abs
			mod_name = path.filename_without_ext.classify
			begin
				mod = Object.const_get(mod_name)
			rescue NameError
				raise "Expected #{path.abs} to define module #{classname}"
			end
			ErbPage::Context.send(:include, mod)
		end
	end
end