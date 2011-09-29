module Ichiban
	def self.define_tasks(rakefile)
		desc 'Generates the static site and puts it in the "compiled" directory. Files will only be compiled as necessary. If a layout has been modified, all files will be recompiled.'
		task :compile => :init do
			Ichiban::Compiler.new.compile
		end
		
		desc 'Generates the static site and puts it in the "compiled" directory. All files will be compiled from scratch.'
		task :fresh => :init do
			Ichiban::Compiler.new.fresh
		end
		
		desc 'Continuously watch for changes and compile files as needed.'
		task :watch => :init do
			Ichiban::Watcher.new.watch
		end
		
		desc 'Initialize Ichiban.'
		task :init do
			Ichiban.configure_for_project(File.dirname(File.expand_path(rakefile)))
		end
	end
end