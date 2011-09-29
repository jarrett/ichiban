module Ichiban
  def self.logger
    @logger ||= Logger.new
  end
  
	class Logger
		def compilation(src, dst)
		  puts "#{src} => #{dst}"
		end
		
		def error(msg)
		  puts msg
		end
	end
end