module Ichiban
  class Command
    def initialize(args, dev = false)
      @task = args.shift
      @args = args
      @dev = dev
    end
    
    def print_usage
      puts(
        "\nUsage: ichiban [command]\n" +
        "Available commands: \n" +
        "  watch\n" +
        "  compile [-a] [path]\n" +
        "  new [path]\n" +
        "  help\n\n" +
        "https://github.com/jarrett/ichiban\n\n"
      )
    end
    
    def run
      case @task
      when 'watch'
        Ichiban.project_root = Dir.getwd
        Ichiban::Watcher.new.start
      when 'compile'
        Ichiban.project_root = Dir.getwd
        compiler = Ichiban::ManualCompiler.new
        if @args.first == '-a'
          compiler.all
        else
          compiler.paths @args
        end
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