require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')
require 'nokogiri'

describe Ichiban do
	def compiled(path = nil)
		path.nil? ? File.join(root, 'compiled') : File.join(root, 'compiled', path)
	end
	
	def parse_compiled(path)
		@parsed_html ||= {}
		@parsed_html[path] ||= Nokogiri.HTML(File.read(compiled(path)))
	end
	
	def root
		File.expand_path(File.join(File.dirname(__FILE__), '../sample'))
	end
	
	before(:all) do
		FileUtils.rm_rf compiled
		FileUtils.mkdir compiled
	end
	
	shared_examples_for 'compilation' do
		it 'creates all the content files and directories as needed' do
			compiled('index.html').should be_file
			compiled('about.html').should be_file
			compiled('staff/index.html').should be_file
		end
		
		it 'renders the content' do
			parse_compiled('index.html').css('h1').inner_html.should == 'Home'
			parse_compiled('about.html').css('h1').inner_html.should == 'About'
			parse_compiled('staff/index.html').css('h1').inner_html.should == 'Employees'
		end
		
		it 'inserts the content into the layout' do
			parse_compiled('index.html').css('head').length.should == 1
		end
		
		it 'copies images' do
			compiled('images/check.png').should be_file
		end
		
		it 'compiles SCSS' do
			File.read(compiled('stylesheets/screen.css')).should include('body h1{color:#f04040}')
		end
		
		it 'copies CSS' do
			compiled('stylesheets/reset.css').should be_file
		end
		
		it 'copies JS' do
			compiled('javascripts/interaction.js').should be_file
		end
		
		context 'with scripts' do
			it 'generates files' do
				compiled('staff/andre-marques.html').should be_file
				compiled('staff/jarrett-colby.html').should be_file
			end
			
			it 'interpolates data into the template' do
				parse_compiled('staff/andre-marques.html').css('h1').inner_html == 'Andre Marques'
				parse_compiled('staff/jarrett-colby.html').css('h1').inner_html == 'Jarrett Colby'
			end
		end
	end
	
	context 'fresh compile' do
		before(:all) do
			Ichiban.configure_for_project(root)
			Ichiban::Compiler.new.fresh
		end
		
		it_should_behave_like 'compilation'
	end
end