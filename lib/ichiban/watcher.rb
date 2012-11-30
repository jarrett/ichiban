module Ichiban
  class Watcher
    def start
      listener = Listen.to(
        File.join(Ichiban.project_root, 'content'),
        File.join(Ichiban.project_root, 'assets')
      )
      .latency(0.5)
      .change do |modified, added, removed|
        (modified + added).each do |path|
          if file = Ichiban::File.from_abs(path)
            file.compile
          end
        end
        removed.each do |path|
          
        end
      end.start
    end
  end
end