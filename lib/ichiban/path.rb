# A Path object is a wrapper around an absolute path.

class Path
  attr_reader :abs
  
  def directory?
    File.directory?(abs)
  end
  
  def dirname
    File.dirname(abs)
  end
  
  def ext
    File.extname(abs).slice(1..-1)
  end
  
  def filename
    File.basename(abs)
  end
  
  def filename_without_ext
    File.basename(abs, File.extname(abs))
  end
  
  def initialize(abs)
    @abs = abs
  end
  
  # Returns a string relative to the given folder
  def relative_from(folder_in_project_root)
    prefix = File.join(Ichiban.project_root, folder_in_project_root)
    raise(ArgumentError, "#{abs} does not start with #{prefix}") unless abs.start_with?(prefix)
    abs.slice(prefix.length..-1)
  end
  
  def replace_ext(new_ext)
    self.class.new(abs.sub(/\..+$/, '.' + new_ext))
  end
  
  # Only meaningful for paths in the compiled directory. Returns a string representing the path from the web root.
  # Assumes Ichiban's standard URL rewriting rules are in effect.
  def web
    web_path = relative_from('compiled')    
    if web_path.end_with?('.html')
      if web_path.end_with?('index.html')
        web_path.slice(0..-11) # Slice index.html off the end
      else
        web_path.slice(0..-6) + '/' # Slice .html off the end and add the trailing slash
      end
    else
      web_path
    end
  end
end