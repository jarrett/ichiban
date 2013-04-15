module Ichiban
  def self.load_bundle
    if Ichiban.project_root and File.exists?(File.join(Ichiban.project_root, 'Gemfile'))
      Bundler.require
    end
  end
end