module Ichiban
  class Watcher
    def start
      listener = Listen.to(
        File.join(Ichiban.project_root, 'content'),
        File.join(Ichiban.project_root, 'assets')
      )
      .latency(0.5)
      .change do |modified, added, removed|
        
      end.start
    end
  end
end