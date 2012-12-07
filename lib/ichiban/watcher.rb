module Ichiban
  class Watcher        
    def initialize(options = {})
      @options = {
        :latency => 0.5
      }.merge(options)
    end
    
    def start(blocking = true)
      @loader = Ichiban::Loader.new
      
      puts 'Starting watcher'
      begin
        @listener = Listen.to(
          File.join(Ichiban.project_root, 'html'),
          File.join(Ichiban.project_root, 'assets'),
          File.join(Ichiban.project_root, 'models'),
          File.join(Ichiban.project_root, 'helpers'),
          File.join(Ichiban.project_root, 'scripts'),
          File.join(Ichiban.project_root, 'data')
        )
        .ignore(/.listen_test$/)
        .latency(@options[:latency])
        .change do |modified, added, deleted|        
          (modified + added).each do |path|
            if file = Ichiban::ProjectFile.from_abs(path)
              @loader.change(file) # Tell the Loader that this file has changed
              begin
                file.update
              rescue => exc
                Ichiban.logger.exception(exc)
              end
            end
          end                    
          deleted.each do |path|
            Ichiban::Deleter.new.delete(path)
          end
        end.start(blocking)
      rescue Interrupt
        puts "\nStopping watcher"
        exit 0
      end
    end
    
    def stop
      if @listener
        @listener.stop
        @listener = nil
      end
    end
  end
end