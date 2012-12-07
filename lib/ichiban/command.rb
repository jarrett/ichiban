module Ichiban
  class Command
    def initialize(args)
      @task = args.shift
      @args = args
    end
    
    def print_usage
      puts "Usage: ichiban <command>"
      puts "  Available commands: watch"
    end
    
    def run
      case @task
      when 'watch'
        Ichiban.project_root = Dir.getwd
        Ichiban::Watcher.new.start
      when 'new'
        Ichiban::ProjectGenerator.new(
          File.expand_path(@args[0])
        ).generate
        puts "Initialized Ichiban project in #{@args[0]}"
      else
        print_usage
      end
    end
  end
end