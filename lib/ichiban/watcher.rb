module Ichiban
  class Watcher        
    def initialize(options = {})
      @options = {
        :latency => 0.5
      }.merge(options)
    end
    
    def start
      @loader = Ichiban::Loader.new
      
      @listener = Listen.to(
        ::File.join(Ichiban.project_root, 'html')#,
        #::File.join(Ichiban.project_root, 'assets')
      )
      .ignore(/.listen_test$/)
      .latency(@options[:latency])
      .change do |modified, added, deleted|
        begin
          (modified + added).each do |path|
            if file = Ichiban::File.from_abs(path)
              @loader.change(file) # Tell the Loader that this file has changed
              file.update
            end
          end          
        rescue => exc
          Ichiban.logger.exception(exc)
        end
        deleted.each do |path|
          Ichiban::Deleter.new.delete(path)
        end
      end.start(false) # nonblocking
    end
    
    def stop
      if @listener
        @listener.stop
        @listener = nil
      end
    end
  end
end