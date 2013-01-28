module Ichiban
  module Helpers
    def capture
      before_buffering = @_erb_out.dup
      @_erb_out.replace('')
      yield
      captured_output = @_erb_out.dup
      @_erb_out.replace(before_buffering)
      captured_output
    end
    
    def concat(str)
      @_erb_out << str
    end
    
    def content_tag(*args)
      options = args.extract_options!
      name = args.shift
      content = block_given? ? yield : args.shift
      output = '<' + name
      output << tag_attrs(options) << ">#{content}</#{name}>"
    end
    
    # Returns the path relative to site root. Includes leading and trailing slash.
    def current_path
      @_current_path
    end
    
    def javascript_include_tag(js_file)
      js_file = js_file + '.js' unless js_file.end_with?('.js')
      path = normalize_path(File.join('/js', js_file))
      content_tag 'script', 'type' => 'text/javascript', 'src' => path
    end
    
    def layout(*stack)
      @_layout_stack = stack
    end
    
    alias_method :layouts, :layout
    
    def _limit_options(hash, keys = [])
      keys = keys.collect(&:to_s)
      hash.inject({}) do |result, (key, value)|
        result[key] = value if (keys.include?(key.to_s) or (block_given? and yield(key, value)))
        result
      end
    end
    
    def link_to(*args)
      options = args.extract_options!
      if args.length == 1
        text = url = args[0]
      else
        text = args[0]
        url = args[1]
      end
      if url.is_a?(String)
        url = normalize_path(url)
      else
        url = url.to_param
      end
      content_tag 'a', text, options.merge('href' => url)
    end
    
    # If the path has a leading slash, it will be made absolute using relative_url_root.
    # Otherwise, it will remain relative.
    def normalize_path(path)
      if path.start_with?('/')
        File.join(relative_url_root, path)
      else
        path
      end
    end
    
    # Adds leading and trailing slashes if none are present
    def path_with_slashes(path)
      path = '/' + path unless path.start_with?('/')
      path << '/' unless path.end_with?('/')
      path
    end
    
    def partial(path)
      file = Ichiban::PartialHTMLFile.new(
        File.join('html', path)
      )
      # Record the dependency like this: 'folder/partial-name' => 'folder/included-file.html'
      Ichiban::Dependencies.update('.partial_dependencies.json', file.partial_name, @_template_path)
      compiler = Ichiban::HTMLCompiler.new(file)
      compiler.ivars = to_hash # to_hash is inherited from Erubis::Context. It's a hash of the instance variables.
      compiler.compile_to_str
    end
    
    def relative_url_root
      Ichiban.config.relative_url_root
    end
    
    def stylesheet_link_tag(css_file, media = 'screen')
      css_file = css_file + '.css' unless css_file.end_with?('.css')
      href = normalize_path(File.join('/css', css_file))
      tag 'link', 'href' => href, 'type' => 'text/css', 'rel' => 'stylesheet', 'media' => media
    end
    
    def tag(*args)
      name = args.shift
      options = args.extract_options!
      open = args.shift
      "<#{name}#{tag_attrs(options)}#{open ? '>' : '/>'}"
    end
    
    def tag_attrs(attrs)
      attrs.inject('') do |result, (key, value)|
        result + " #{key}=\"#{h(value)}\""
      end
    end
  end
end