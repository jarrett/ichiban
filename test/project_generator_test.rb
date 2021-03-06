require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestProjectGenerator < Minitest::Test
  def project_dest
    File.expand_path(File.join(File.dirname(__FILE__), '../tmp_project'))
  end
  
  def teardown
    if File.exist?(project_dest)
      FileUtils.rm_rf project_dest
    end
  end
  
  def test_generate_project
    Ichiban::ProjectGenerator.new(project_dest).generate
    # Test that each of these files exists:
    %w(
      deploy.sh
      html/index.html
      layouts/default.html
      assets/css/screen.scss
      assets/js/interaction.js
      assets/img
      assets/misc/readme.txt
      data/readme.txt
      helpers/readme.txt
      models/readme.txt
      scripts/readme.txt
      compiled/index.html
      compiled/css/screen.css
      compiled/js/interaction.js
      compiled/img
      compiled/.htaccess
    ).each do |dest_file|
      abs = File.join(project_dest, dest_file)
      assert File.exist?(abs), "Expected #{abs} to exist"
    end
  end
end