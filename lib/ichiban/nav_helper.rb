module Ichiban
  module NavHelper
  
    def nav(items, options = {})
      Nav.new(items, options, self).to_html
    end
    
    class Nav
      def initialize(items, options, context)
        @items = items
        @options = options
        @ctx = context
      end
      
      def to_html
        ul(@items, 0)
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
      
      
      
      #def merge_classes(current_classes, added_classes)
      #  current_classes = current_classes.split(/ +/)
      #  added_classes = added_classes.split(/ +/)
      #  (current_classes + added_classes).uniq.join(' ')
      #end
      
      # Recursive. Checks whether any item in the menu, or any item in any of its descendant
      # menus, has a path that *starts with* the current path. E.g. if a menu or its descendants
      # have a link to '/a/b/c/', and we're at '/a/b/c/d/e/f/', then this method returns true.
      def menu_matches_current_path?(items)
        !items.detect do |item|
          if current_path_starts_with?(item[1])
            # The current path matches this item, so we can stop looking.
            # menu_matches_current_path? will return true.
            true
          elsif item[2].is_a?(Array)
            # If an item has a sub-menu, then that menu must be the third element of the array.
            # (The format is [text, path, sub_menu, li_options].) So we recursively search the
            # descendant menu(s) of this item.
            menu_matches_current_path?(items[2])
          end
        end.nil?
      end
      
      # Recursive
      #def sub_menu_contains_current_path?(items)
      #  !items.detect do |item|
      #    if current_path?(item[1])
      #      true
      #    elsif item[2].is_a?(Array)
      #      sub_menu_contains_current_path?(item[2])
      #    elsif item[3].is_a?(Array)
      #      sub_menu_contains_current_path?(item[3])
      #    else
      #      false
      #    end
      #  end.nil?
      #end
      
      # Recursive
      def ul(items, depth)
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
            path = item.shift
            
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
              if fourth.is_a?(Hash)
                li_attrs = fourth
              end
            when Hash
              li_attrs.merge!(third)
            end
            
            # If the path has a leading slash, consider it absolute and prepend it with
            # relative_url_root. Otherwise, it's a relative URL, so do nothing to it.
            path = @ctx.normalize_path(path)
            
            # Create the <li>, and recur for the sub-menu if applicable
            lis << @ctx.content_tag('li', li_attrs) do
              li_inner_html = ''
              
              # Create the <a> or <span> tag for this item.
              if current_path?(path)
                li_inner_html << @ctx.content_tag('span', text, 'class' => 'selected')
              else
                if current_path_starts_with?(path)
                  a_attrs = {'class' => 'above-selected'}
                else
                  a_attrs = {}
                end
                li_inner_html << @ctx.link_to(text, path, a_attrs)
              end
            
              # This item's sub-menu should be open if and only if:
              #
              # 1. we are at or inside the item's path; or
              # 2. we are at or inside a path included in any of this item's descendant menus.
              
              if sub_menu
                sub_menu_open = (
                  current_path_starts_with?(path) or
                  menu_matches_current_path?(sub_menu)
                )
              else
                sub_menu_open = false
              end
              
              # If the sub-menu is open, then we recursively generate its HTML
              # and append it to this <li>.
              if sub_menu_open
                li_inner_html << ul(sub_menu, depth + 1)
              end
              
              li_inner_html
            end
            
            #lis << @ctx.content_tag('li', li_attrs) do
            #  in_sub_path = (path != '/' and @options[:consider_sub_paths] and @ctx.path_with_slashes(@ctx.current_path).start_with?(@ctx.path_with_slashes(path)))
            #  if current_path?(path)
            #    li_inner_html = @ctx.content_tag('span', text, 'class' => 'selected')
            #  elsif (sub_menu and sub_menu_contains_current_path?(sub_menu)) or in_sub_path
            #    li_inner_html = @ctx.link_to(text, path, 'class' => 'ancestor_of_selected')
            #  else
            #    li_inner_html = @ctx.link_to(text, path)
            #  end
            #  if sub_menu and (current_path?(path) or sub_menu_contains_current_path?(sub_menu) or in_sub_path)
            #    li_inner_html << ul(sub_menu, depth + 1)
            #  end
            #  li_inner_html
            #end
            lis
          end
        end
      end
    end
  end
end