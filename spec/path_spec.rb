require 'ichiban'

include Ichiban

describe Path do	
	before :each do
		Ichiban.stub(:compiler => mock(:project_root => '/project'))
	end
	
	describe '#abs' do
		it 'returns the absolute path' do
			Path.new('/project/content/index.html').abs.should == '/project/content/index.html'
		end
	end
	
	describe '#base' do
		it 'returns the filename without an extension' do
			Path.new('/project/content/index.html').base.should == 'index'
		end
	end
	
	describe '#from' do
		it 'returns the path relative to the given subfolder' do
			Path.new('/project/content/foo/index.html').from('content').should == 'foo/index.html'
		end
		
		it 'raises if the file is not in the given subfolder' do
			lambda { Path.new('/project/content/foo/index.html').from('errors') }.should raise_error
		end
	end
	
	describe '#from_project_root' do
		it 'returns the path relative to the project root' do
			Path.new('/project/content/foo/index.html').from_project_root.should == 'content/foo/index.html'
		end
	end
		
	describe '#from_site_root' do
		it 'returns the path relative to the base URL for HTML files (sans extension, with trailing slash)' do
			Path.new('/project/content/foo/bar.html').from_site_root.should == 'foo/bar/'
		end
		
		it 'returns the folder path relative to the base URL for index files (with trailing slash)' do
			Path.new('/project/content/foo/index.html').from_site_root.should == 'foo/'
		end
		
		it 'returns the path relative to the base URL for non-HTML files (with extension, without trailing slash)' do
			Path.new('/project/content/foo/bar.pdf').from_site_root.should == 'foo/bar.pdf'
		end
		
		it 'works for paths in the compiled folder' do
			Path.new('/project/compiled/foo/bar.html').from_site_root.should == 'foo/bar/'
		end
	end
		
	describe '#in?' do
		it 'returns true if the file is in the given subfolder' do
			Path.new('/project/content/foo/index.html').in?('content').should be_true
		end
		
		it 'returns false if the file is not in the given subfolder' do
			Path.new('/project/content/foo/index.html').in?('errors').should be_false
		end
	end
		
	describe '.new' do
		it 'uses the given absolute path' do
			Path.new('/project/content/index.html').abs.should == '/project/content/index.html'
		end
		
		it 'determines the correct absolute path when the given path is relative to the project root' do
			Path.new('content/index.html', :project).abs.should == '/project/content/index.html'
		end
		
		it 'determines the correct absolute path when the given path is relative to a subfolder' do
			Path.new('foo/index.html', 'content').abs.should == '/project/content/foo/index.html'
		end
	end
		
	describe '#to_compiled' do
		it 'maps content files to the right output path' do
			Path.new('/project/content/foo/bar.html').to_compiled.abs.should == '/project/compiled/foo/bar.html'
		end
		
		it 'maps error files to the right output path' do
			Path.new('/project/errors/404.html').to_compiled.abs.should == '/project/compiled/404.html'
		end
		
		it 'maps image files to the right output path' do
			Path.new('/project/images/logo.png').to_compiled.abs.should == '/project/compiled/images/logo.png'
		end
		
		it 'maps javascript files to the right output path' do
			Path.new('/project/javascripts/prototype.js').to_compiled.abs.should == '/project/compiled/javascripts/prototype.js'
		end
		
		it 'maps css files to the right output path' do
			Path.new('/project/stylesheets/screen.css').to_compiled.abs.should == '/project/compiled/stylesheets/screen.css'
		end
	end
end