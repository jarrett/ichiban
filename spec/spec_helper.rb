# Put the working directory's version of Ichiban first in the list of load paths. That way,
# we won't load an installed version of the gem.
$:.unshift File.expand_path(File.join(File.dirname(__FILE__)), '../lib')

require 'ichiban'

RSpec::Matchers.define :be_file do
	match { |path| File.exists?(path) }
end