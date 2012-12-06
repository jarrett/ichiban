module Ichiban
  def self.logger
    @logger ||= Logger.new
  end
  
  class Logger
    def self.ansi?
      @ansi
    end
    
    def ansi?
      self.class.ansi?
    end
    
    def compilation(src, dst)
      src = src.slice(Ichiban.project_root.length + 1..-1)
      dst = dst.slice(Ichiban.project_root.length + 1..-1)
      msg = "#{src} -> #{dst}"
      if ansi?
        msg = ANSI.color(msg, :green)
      end
      out msg
    end
    
    def deletion(src, dst = nil)
      src = src.slice(Ichiban.project_root.length + 1..-1)
      if dst
        dst = dst.slice(Ichiban.project_root.length + 1..-1)
      end
      if dst
        msg = "Deleted: #{src} -> #{dst}"
      else
        msg = "Deleted: #{src}"
      end
      if ansi?
        msg = ANSI.color(msg, :cyan)
      end
      out msg
    end
    
    def exception(exc)
      msg = "#{exc.class.to_s}: #{exc.message}\n" + exc.backtrace.collect { |line| '  ' + line }.join("\n")
      if ansi?
        msg = ANSI.color(msg, :red)
      end
      out msg
    end
    
    def initialize
      @out = STDOUT
    end
    
    def reload(path)
      path = path.slice(Ichiban.project_root.length + 1..-1)
      msg = "#{path} triggered a reload"
      if ansi?
        msg = ANSI.color(msg, :magenta)
      end
      out msg
    end
    
    def out=(io)
      @out = io
    end
    
    def out(msg)
      @out.puts msg
    end
    
    def script_run(ind_path, dep_path)
      ind_path = ind_path.slice(Ichiban.project_root.length + 1..-1)
      dep_path = dep_path.slice(Ichiban.project_root.length + 1..-1)
      msg = "#{dep_path} running due to change in #{ind_path}"
      if ansi?
        msg = ANSI.color(msg, :magenta)
      end
      out msg
    end
    
    def warn(msg)
      if ansi?
        msg = ANSI.color(msg, :red)
      end
      out msg
    end
    
    begin
      require 'ansi'
      @ansi = true
    rescue LoadError
      Ichiban.logger.out("Try `gem install ansi` for colorized output")
    end
  end
end