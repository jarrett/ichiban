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
      Ichiban.project_root = Dir.getwd
      case @task
      when 'watch'
        Ichiban::Watcher.new.start
      else
        print_usage
      end
    end
  end
end