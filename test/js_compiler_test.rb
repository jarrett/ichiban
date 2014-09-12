require 'test_helper'

class JSCompilerTest < MiniTest::Test
  include ExampleDirectory
  include CompilationAssertions
  include LoggingAssertions
  
  def teardown
    super
    Ichiban.project_root = nil
  end
  
  def compiler(path_in_js)
    Ichiban::JSCompiler.new(Ichiban::ProjectFile.from_abs(File.join(
      Ichiban.project_root, 'assets/js/', path_in_js
    )))
  end
  
  # Pass in an a hash from paths to contents.
  def stub_file_read(files)
    expected_paths = files.keys
    expectation = File.expects(:read).times(files.length).with do |actual_path|
      # Custom parameter matcher for #with. This is the only way in Mocha to specify a
      # sequence of calls with different params.
      expected_paths.shift == actual_path
    end
    files.each do |path, contents|
      expectation.returns contents
    end
  end
  
  #def stub_js_manifests(js_hash)
  #  mock_config = mock
  #  Ichiban.expects(:config).returns(mock_config).at_least_once
  #  mock_config.expects(:js_manifests).returns(js_hash).at_least_once
  #end
  
  def test_compile
    copy_example_dir
    assert_logged('') do
      compiler('home.js').compile
    end
    assert_compiled 'js/site.js'
    assert_compiled 'js/site.js.map'
  end
  
  def test_compile_with_source_not_in_manifests
    copy_example_dir
    comp = compiler 'x.js'
    comp.compile # Just make sure it doesn't raise.
  end
  
  def test_compile_paths
    init_example_dir
    stub_file_read(
      'assets/js/animation.js' => %Q(
        $(document).ready(function() {
          $('h1').animate({opacity: 1}, {duration: 200});
        });
      ),
      'assets/js/slideshow.js' => %Q(
        $.slideshow('#slides');
      ),
      'assets/js/ajax.js' => %Q(
        (function() {
          var inputValid = true;
          if (inputValid) {
            $.ajax('/path');
          } else {
            alert('Bad input');
          }
        })();
      )
    )
    paths = ['assets/js/animation.js', 'assets/js/slideshow.js', 'assets/js/ajax.js']
    comp = compiler('irrelevant.js')
    actual_js, actual_map = comp.send(:compile_paths, paths, '/js', 'site.js', 'site.js.map')
    expected_js = %Q($(document).ready(function(){$("h1").animate({opacity:1},{duration:200})}),$.slideshow("#slides"),function(){var a=!0;a?$.ajax("/path"):alert("Bad input")}();\n//# sourceMappingURL=/js/site.js.map)
    expected_map = %Q({"version":3,"file":"site.js","sources":["/js/animation.js","/js/slideshow.js","/js/ajax.js"],"names":[],"mappings":"AACA,EAAA,UAAA,MAAA,WACA,EAAA,MAAA,SAAA,QAAA,IAAA,SAAA,QCDA,EAAA,UAAA,WCAA,WACA,GAAA,IAAA,CACA,GACA,EAAA,KAAA,SAEA,MAAA"})
    assert_equal expected_js, actual_js
    assert_equal expected_map, actual_map
  end
end