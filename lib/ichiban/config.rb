module Ichiban
	PAGE_FILE_EXTENSIONS = ['.html', '.markdown']
	
	def self.configure
		yield config
	end
	
	def self.compile(project_root)
		Compiler.new(project_root)
		yield @compiler
		@compiler = nil
	end
	
	def self.compiler
		@compiler or 'Ichiban.compiler not initialized'
	end
	
	def self.compiler=(c)
		@compiler = c
	end
	
	def self.config
		@config or 'Ichiban.config not initialized'
	end
	
	def self.initialize(project_root)
		@project_root = project_root
		@config = ::Ichiban::Config.new
		require File.join(project_root, 'config.rb')
	end
	
	def self.project_root
		@project_root
	end
	
	class Config
		attr_accessor :ignored_less_files, :ignored_scss_files
		attr_writer :relative_url_root
		
		def initialize
			@ignored_less_files = []
		end
		
		def relative_url_root
			@relative_url_root or raise('Relative URL root not set')
		end
	end
end