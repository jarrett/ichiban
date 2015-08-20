module Ichiban
  class Watcher
    def initialize(options = {})
      @options = {
        :latency => 0.5
      }.merge(options)
      @listen_event_log = []
      @loader = Ichiban::Loader.new
    end
    
    attr_reader :listener
    
    attr_reader :listen_event_log
    
    # The test suite calls this method directly
    # to bypass the Listen gem for certain tests.
    def on_change(modified, added, deleted)
      # Modifications and additions are treated the same.
      (modified + added).uniq.each do |path|
        if file = Ichiban::ProjectFile.from_abs(path)
          begin
            @loader.change(file) # Tell the Loader that this file has changed
            file.update
          rescue Exception => exc
            Ichiban.logger.exception(exc)
          end
        end
      end
      
      # Deletions are handled specially.
      deleted.each do |path|
        Ichiban::Deleter.new.delete_dest(path)
      end
      
      # Finally, propagate this change to any dependent files.
      (modified + added + deleted).uniq.each do |path|
        begin
          Ichiban::Dependencies.propagate(path)
        rescue => exc
          Ichiban.logger.exception(exc)
        end
      end
    end
    
    def start
      Ichiban.logger.out 'Starting watcher'
      begin
        @listener = Listen.to(
          Ichiban.project_root,
          ignore: /.listen_test$/,
          latency: @options[:latency]
        ) do |modified, added, deleted|
          @listen_event_log << [modified, added, deleted]
          on_change modified, added, deleted
        end
        @listener.start
        sleep
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