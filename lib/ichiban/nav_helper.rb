module Ichiban
  module NavHelper
  
    def nav(items, options = {})
      unless items.is_a?(Array)
        raise "Expected first parameter of NavHelper#nav to be an Array, but got: #{items.inspect}"
      end
      options = {sub_paths: :expand}.merge(options)
      Nav.new(items, options, self).to_html
    end
    
    class Nav
      def initialize(items, options, context)
        @items = items
        @options = options
        @ctx = context
      end
      
      def to_html
        ul(@items, 0, @options)
      end
      
      private
      
      # Returns true if and only if the current path is *identical* to the passed-in path.
      def current_path?(path)
        @ctx.path_with_slashes(@ctx.current_path) == @ctx.path_with_slashes(path)
      end
      
      # Returns true if and only if the current path *starts with* the passed-in path.
      # So sub-paths will match.
      def current_path_starts_with?(path)
        @ctx.path_with_slashes(@ctx.current_path).start_with?(@ctx.path_with_slashes(path))
      end
            
      # Recursive.
      def menu_matches_current_path?(path, sub_menu, options)        
        # If the menu item matches the current path exactly, return true.
        current_path?(path) or
        
        # If we're allowed to consider sub-paths, and the current path starts with the
        # menu item's path, return true. E.g. current path /a/b/c/ and menu item path
        # /a/b/.
        (options[:sub_paths] != :collapse and current_path_starts_with?(path)) or
        
        # The path for this menu item did not match. So search recursively for a matching
        # path in this item's sub-menu.
        (!sub_menu.nil? and sub_menu.any? do |_, sub_path, sub_sub_menu|
          menu_matches_current_path? sub_path, sub_sub_menu, options
        end)
      end
      
      # Recursive
      def ul(items, depth, options)
        # If we're in the outermost menu, add any passed-in <ul> attributes
        ul_options = (
          depth == 0 ?
          (@ctx._limit_options(@options, %w(id class)) do |key, value|
            key.to_s.start_with?('data-')
          end) :
          {}
        )
        
        @ctx.content_tag('ul', ul_options) do
          items.inject('') do |lis, item|
            text = item.shift
            unless text.is_a?(String)
              raise "Invalid data structure passed to nav. Expected String, but got #{text.inspect}"
            end
            path = item.shift
            unless path.is_a?(String)
              raise "Invalid data structure passed to nav. Expected String, but got #{path.inspect}"
            end
            
            # After the text and path, there are two optional parameters: Sub-menu (an array)
            # and <li> options (a hash). If both exist, they must come in that order. But either
            # one can exist without the other.
            #
            # Initialiy, sub_menu and li_attrs are set to default values. These have a chance to
            # be overwritten when we look at the third and fourth parameters.
            
            sub_menu = nil
            li_attrs = {}
            
            third = item.shift
            fourth = item.shift
            
            case third
            when Array
              sub_menu = third
              case fourth
              when Hash
                li_attrs = fourth
              when nil
                # Do nothing.
              else
                raise "Invalid data structure passed to nav. Expected Hash or nil, but got #{fourth.inspect}"
              end
            when Hash
              li_attrs.merge!(third)
            when nil
              # Do nothing.
            else
              raise "Invalid data structure passed to nav. Expected Array, Hash, or nil, but got #{third.inspect}"
            end
            
            # If the path has a leading slash, consider it absolute and prepend it with
            # relative_url_root. Otherwise, it's a relative URL, so do nothing to it.
            path = @ctx.normalize_path(path)
            
            # Create the <li>, and recur for the sub-menu if applicable
            lis << @ctx.content_tag('li', li_attrs) do
              li_inner_html = ''
              
              sub_menu_open = (
                !sub_menu.nil? and
                menu_matches_current_path?(path, sub_menu, options)
              )
              
              # Create the <a> or <span> tag for this item.
              if current_path?(path)
                li_inner_html << @ctx.content_tag('span', text, 'class' => 'selected')
              else
                if sub_menu_open
                  a_attrs = {'class' => 'above-selected'}
                else
                  a_attrs = {}
                end
                li_inner_html << @ctx.link_to(text, path, a_attrs)
              end
              
              # If the sub-menu is open, then we recursively generate its HTML
              # and append it to this <li>.
              if sub_menu_open
                li_inner_html << ul(sub_menu, depth + 1, options)
              end
              
              li_inner_html
            end
            
            lis
          end
        end
      end
    end
  end
end