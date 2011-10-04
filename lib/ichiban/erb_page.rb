module Ichiban
  class ErbPage < Erubis::Eruby
    def add_preamble(src)
      src << "@_erb_out = _buf = '';"
    end
    
    class Context < Erubis::Context
      include ::Ichiban::Helpers
      include ::Erubis::XmlHelper
      
      def layout_stack
        @_layout_stack or ['default']
      end
    end
  end
end