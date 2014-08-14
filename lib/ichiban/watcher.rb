module Ichiban
  class Watcher
    def initialize(options = {})
      @options = {
        :latency => 0.5
      }.merge(options)
      @listen_event_log = []
    end
    
    attr_reader :listener
    
    attr_reader :listen_event_log
    
    def start
      @loader = Ichiban::Loader.new
      
      Ichiban.logger.out 'Starting watcher'
      begin
        @listener = Listen.to(
          Ichiban.project_root,
          ignore: /.listen_test$/,
          latency: @options[:latency]
        ) do |modified, added, deleted|
          @listen_event_log << [modified, added, deleted]
          (modified + added).uniq.each do |path|
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
            Ichiban::Deleter.new.delete_dest(path)
          end
          (modified + added + deleted).uniq.each do |path|
            begin
              Ichiban::Dependencies.propagate(path)
            rescue => exc
              Ichiban.logger.exception(exc)
            end
          end
        end
        @listener.start
      rescue Interrupt
        stop
        exit 0
      end
    end
    
    def stop
      if @listener
        Ichiban.logger.out "Stopping watcher"
        @listener.stop
        @listener = nil
      end
    end
  end
end