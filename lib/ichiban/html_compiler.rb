module Ichiban
  class HTMLCompiler
    def compile
      FileUtils.mkdir_p File.dirname(@html_file.dest)
      File.open(@html_file.dest, 'w') do |f|
        f << compile_to_str
      end
      Ichiban.logger.compilation(@html_file.abs, @html_file.dest)
    end
    
    def compile_to_str 
      # @_template_path is a path relative to the html folder. It points to the current *complete*
      # HTML file being rendered. I.e. if we're currently rendering a partial, @_template_path
      # will *not* point to the partial file.
      #
      # _template_path may be overwritten later when we look at @ivars. This is good, because
      # if we're in a partial, and the including template has already set _template_path, we want
      # to inherit that value. (When you call partial from a template, all of the including template's
      # instance variables, including @_template_path, will be put into @ivars.)
      ivars_for_ctx = {:_template_path => @html_file.rel.slice('html/'.length..-1)}
      
      if @html_file.is_a?(Ichiban::HTMLFile)
        ivars_for_ctx[:_current_path] = @html_file.web_path
      end
      ivars_for_ctx.merge!(@ivars) if instance_variable_defined?('@ivars')
      
      ctx = Ichiban::HTMLCompiler::Context.new(ivars_for_ctx)
      
      inner_html = Eruby.new(File.read(@html_file.abs), :filename => @html_file.abs).evaluate(ctx)
      
      # Compile Markdown if necessary
      if (@html_file.abs.end_with?('.markdown') or @html_file.abs.end_with?('.md'))
        inner_html = Ichiban::Markdown.compile(inner_html) # Will look for installed Markdown gems
      end
      
      # Do layouts if appropriate
      if @html_file.is_a?(Ichiban::HTMLFile)
        wrap_in_layouts(ctx, inner_html)
      else
        # It's a PartialHTMLFile
        inner_html
      end
    end
    
    # Takes an instance of Ichiban::HTMLFile or Ichiban::PartialHTMLFile
    def initialize(html_file)
      @html_file = html_file
    end
    
    attr_writer :ivars
    
    def wrap_in_layouts(ctx, inner_rhtml)
      ctx.layout_stack.reverse.inject(inner_rhtml) do |html, layout_name|
        layout_path = File.join(Ichiban.project_root, 'layouts', layout_name + '.html')
        unless File.exist?(layout_path)
          raise "Layout does not exist: #{layout_path}"
        end
        eruby = Eruby.new(
          File.read(layout_path),
          :filename => layout_path
        )
        html = eruby.evaluate(ctx) { html }
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
      include Ichiban::NavHelper
      include Erubis::XmlHelper
      include ERB::Util # Give us #h
      
      # An array of helper modules. Each Context instance will be extended with them on init.
      # We could just include the modules in this class. But that would break reloading. Once a
      # module has been included, deleting the module doesn't un-include it. So instead, we limit
      # the damage to a particular instance of Context.
      @user_defined_helpers = []
      
      def self.add_user_defined_helper(mod)
        unless @user_defined_helpers.include?(mod)
          @user_defined_helpers << mod
        end
      end
      
      def self.clear_user_defined_helpers
        @user_defined_helpers = []
      end
      
      def initialize(vars)
        super(vars)
        self.class.user_defined_helpers.each do |mod|
          extend(mod)
        end
      end
      
      def layout_stack
        instance_variable_defined?('@_layout_stack') ? @_layout_stack : ['default']
      end
      
      def self.user_defined_helpers
        @user_defined_helpers
      end
    end
  end
end