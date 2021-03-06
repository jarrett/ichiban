module Ichiban
  class Deleter
    # Deletes a file's associated destination file, if any.
    def delete_dest(path)
      file = Ichiban::ProjectFile.from_abs(path)
      # file will be nil if the path doesn't map to a known subclass of IchibanFile. Furthermore,
      # even if file is not nil, it may be a kind of IchibanFile that does not have a destination.
      if file and file.has_dest?
        dest = file.dest
      else
        dest = nil
      end
      if dest and File.exist?(dest)
        FileUtils.rm(dest)
      end
    
      # Log the deletion(s)
      Ichiban.logger.deletion(path, dest)
    end
  end
end