require 'fileutils'

module Ichiban
	class Path
		def abs
			@abs
		end
		
		def base
			File.basename(@abs, ext)
		end
		
		def copy_out
			create_output_dir
			FileUtils.cp_r @abs, to_compiled.abs
		end
		
		def create_output_dir
			FileUtils.mkdir_p File.dirname(to_compiled.abs)
		end
		
		def ext
			File.extname(@abs)
		end
		
		def from(folder_in_project_root)
			@from[folder_in_project_root] ||= in?(folder_in_project_root) ?
				strip_prefix(from_project_root, folder_in_project_root) :
				raise("@abs is not in the #{folder_in_project_root} folder")
		end
		
		def from_project_root
			@from_project_root = strip_prefix(@abs, Ichiban.project_root)
		end
		
		# Unlike the other #from_ methods, this one does not count on the file being
		# in any particular folder. Instead, it intelligently maps the filesystem path to
		# a URI path. Because it returns a URI path and *not* a filesystem path,
		# it will strip the .html extension but leave other extensions intact.
		def from_site_root
			if @from_site_root.nil?
				path = (in?('compiled') ? self : to_compiled).from('compiled')
				if path.end_with?('.html')
					path = strip_suffix(path, '.html')
					path = strip_suffix(path, 'index')
					@from_site_root = path.end_with?('/') ? path : path + '/'
				else
					@from_site_root = path
				end
			end
			@from_site_root
		end
		
		def in?(path_from_project_root)
			@in[path_from_project_root] ||= from_project_root.start_with?(path_from_project_root)
		end
		
		def initialize(path, from = :abs, new_ext = nil)
			raise "#{path} is an absolute path" if from != :abs and path.start_with?('/')
			@abs = case from
			when :abs
				raise "#{path} is not an absolute path" unless path.start_with?('/')
				path
			when :project
				File.join(Ichiban.project_root, path)
			else
				File.join(Ichiban.project_root, from.to_s, path)
			end
			replace_ext!(new_ext) if new_ext
			@from = {}
			@in = {}
		end
		
		def replace_ext!(new_ext)
			@abs = @abs.slice(0, @abs.length - ext.length) + new_ext
			self
		end
		
		# Return a new Path within the compiled folder, taking into account our mapping rules
		def to_compiled
			@to_compiled ||= case
			when from_project_root == 'htaccess.txt'
				self.class.new '.htaccess', :compiled
			when in?('content')
				self.class.new from('content'), 'compiled'
			when in?('errors')
				self.class.new from('errors'), 'compiled'
			when in?('javascripts')
				self.class.new from('javascripts'), 'compiled/javascripts'
			when in?('images')
				self.class.new from('images'), 'compiled/images'
			when in?('stylesheets')
				self.class.new from('stylesheets'), 'compiled/stylesheets'
			else
				raise "Don't know how to map #{@abs} to compiled path"
			end
		end
		
		def to_s
			@abs
		end
		
		private
		
		def strip_prefix(str, prefix)
			str.start_with?(prefix) ?
				str.slice(prefix.length + 1, str.length - 1) :
				str
		end
		
		def strip_suffix(str, suffix)
			str.end_with?(suffix) ?
				str.slice(0, str.length - suffix.length) :
				str
		end
	end
end