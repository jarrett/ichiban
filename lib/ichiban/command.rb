module Ichiban
  class Command
    def initialize(args)
      @task = args.shift
      @args = args
    end
    
    def print_usage
      puts(
        "\nUsage: ichiban [command]\n" +
        "Available commands: \n" +
        "  watch\n" +
        "  new [path]\n" +
        "  help\n\n" +
        "https://github.com/jarrett/ichiban\n\n"
      )
    end
    
    def run
      case @task
      when 'watch'
        Ichiban.project_root = Dir.getwd
        Ichiban.load_bundle
        Ichiban::Watcher.new.start
      when 'new'
        Ichiban::ProjectGenerator.new(
          File.expand_path(@args[0])
        ).generate
        Ichiban.logger.out "Initialized Ichiban project in #{@args[0]}"
      when 'version', '-v', '--version'
        puts "Ichiban version #{::Ichiban::VERSION}"
      else
        print_usage
      end
    end
  end
end