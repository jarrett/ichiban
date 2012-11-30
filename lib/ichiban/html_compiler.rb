module Ichiban
  class HTMLCompiler
    def compile
      ::File.open(@html_file.dest, 'w') do |f|
        f << compile_to_str
      end
      Ichiban.logger.compilation(@html_file.abs, @html_file.dest)
    end
    
    def compile_to_str
      inner_rhtml = ::File.read(@html_file.abs)
      if (@html_file.abs.end_with?('.markdown') or @html_file.abs.end_with?('.md'))
        inner_rhtml = Ichiban::Markdown.compile(inner_rhtml) # Will look for installed Markdown gems
      end
      ctx = Ichiban::HTMLCompiler::Context.new(:_current_path => @html_file.dest_rel_to_compiled)
      wrap_in_layouts(ctx, inner_rhtml)
    end
    
    # Takes an instance of Ichiban::HTMLFile
    def initialize(html_file)
      @html_file = html_file
    end
    
    def wrap_in_layouts(ctx, inner_rhtml)
      ctx.layout_stack.reverse.inject(inner_rhtml) do |html, layout_name|
        layout_path = ::File.join(Ichiban.project_root, 'layouts', layout_name + '.html')
        eruby = Eruby.new(
          ::File.read(layout_path),
          :filename => layout_path
        )
        html = eruby.evaluate(ctx) { html }
        Ichiban::Dependencies.update('.layout_dependencies.json', layout_name, @html_file.abs)
        html
      end
    end
    
    class Eruby < Erubis::Eruby
      def add_preamble(src)
        src << "@_erb_out = _buf = '';"
      end
    end
    
    class Context < Erubis::Context
      include Ichiban::Helpers
      include Erubis::XmlHelper
      
      def layout_stack
        @_layout_stack or ['default']
      end
    end
  end
end