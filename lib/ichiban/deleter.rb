module Ichiban
  class Deleter
    # Deletes a file and any associated destination file. Does a git rm if possible.
    def delete(path)
      file = Ichiban::File.from_abs(path)
      # file will be nil if the path doesn't map to a known subclass of Ichiban::File. Furthermore,
      # even if file is not nil, it may be a kind of Ichiban::File that does not have a destination.
      if file and file.has_dest?
        dest = file.dest
      else
        dest = nil
      end
      
      if Ichiban.gitted?
        # If Grit is not installed, Ichiban.grit returns an instance of Grit::Repo. Else, it returns nil.
        if repo = Ichiban.grit
          puts ANSI.color('Gitted!', :magenta, :bold)
          # Grit::Repo#remove doesn't complain if you try to git rm a nonexistent file, or one that
          # has already been git rm'ed. So we can safely do these two operations without performing
          # any checks first.
          puts path
          repo.remove(path)
          if dest
            repo.remove(dest)
          end
        else
          Ichiban.logger.warn(
            "You deleted a file in a project managed by git, but Grit is not installed\n" +
            "Thus, Ichiban cannot `git rm` the files for you. Please `gem install grit`\n" +
            "or else manually `git rm` the files yourself. (Don't forget the compiled files.)\n" +
            "The deleted file was:\n" + path
          )
          if dest and ::File.exists?(dest)
            # Project under git but Grit not installed, so just do a regular filesystem rm for the destination
            FileUtils.rm(dest)
          end
        end
      elsif dest and ::File.exists?(dest)
        # Project not under git, so just do a regular filesystem rm for the destination
        FileUtils.rm(dest)
      end
    
      # Log the deletion(s)
      Ichiban.logger.deletion(path, dest)
    end
  end
end