module Ichiban
  class Watcher    
    def delete_file(path)
      file = Ichiban::File.from_path(abs)
      # file will be nil if the path doesn't map to a known subclass of Ichiban::File. Furthermore,
      # even if file is not nil, it may be a kind of Ichiban::File that does not have a destination.
      if file and file.has_dest?
        dest = file.dest
      else
        dest = nil
      end
      
      if Ichiban.gitted?
        # If Grit is isntalled, Ichiban.grit returns an instance of Grit::Repo. Else, it returns nil.
        if repo = Ichiban.grit
          # Grit::Repo#remove doesn't complain if you try to git rm a nonexistent file, or one that
          # has already been git rm'ed. So we can safely do these two operations without performing
          # any checks first.
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
          # Project under git but Grit not installed, so just do a regular filesystem rm for the destination
          FileUtils.rm(dest)
        end
      else
        # Project not under git, so just do a regular filesystem rm for the destination
        FileUtils.rm(dest)
      end
    
      # Log the deletion(s)
      Ichiban.logger.deletion(path, dest)
    end
    
    def initialize(options = {})
      @options = {
        :latency => 0.5
      }.merge(options)
    end
    
    def start
      @listener = Listen.to(
        ::File.join(Ichiban.project_root, 'html')#,
        #::File.join(Ichiban.project_root, 'assets')
      )
      .latency(@options[:latency])
      .change do |modified, added, deleted|
        begin
          #puts ANSI.color("Change!", :magenta)
          (modified + added).each do |path|
            if file = Ichiban::File.from_abs(path)
              file.update
            end
          end
          deleted.each do |path|
            #delete_file(path)
          end
        rescue => exc
          Ichiban.logger.exception(exc)
        end
      end.start(false) # nonblocking
    end
    
    def stop
      puts 'stopping listening'
      if @listener
        @listener.stop
        @listener = nil
      end
    end
  end
end