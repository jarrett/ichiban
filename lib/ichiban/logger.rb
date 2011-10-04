module Ichiban
  def self.logger
    @logger ||= Logger.new
  end
  
  class Logger
    def compilation(src, dst)
      out "#{src} => #{dst}"
    end
    
    def exception(exc)
      out "#{exc.class.to_s}: #{exc.message}\n" + exc.backtrace.collect { |line| '  ' + line }.join("\n")
    end
    
    def out(msg)
      puts msg
    end
  end
end