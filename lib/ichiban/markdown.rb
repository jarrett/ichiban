module Ichiban
  module Markdown    
    def self.compile(src)
      require_markdown
      case @strategy
      when :kramdown
        Kramdown::Document.new(src).to_html
      when :multimarkdown
        MultiMarkdown.new(src).to_html
      when :redcarpet
        @redcarpet.render(src)
      when :maruku
        Maruku.new(src).to_html
      when :rdiscount
        RDiscount.new(src).to_html
      else
        raise "unrecognized @strategy: #{@strategy}"
      end
    end
    
    def self.require_markdown
      unless @markdown_loaded
        case Ichiban.try_require('kramdown', 'multimarkdown', 'redcarpet', 'maruku', 'rdiscount')
        when 'kramdown'
          @strategy = :kramdown
        when 'multimarkdown'
          @strategy = :multimarkdown
        when 'redcarpet'
          @redcarpet = Redcarpet::Markdown.new(Redcarpet::Render::XHTML.new)
          @strategy = :redcarpet
        when 'maruku'
          @strategy = :maruku
        when 'rdiscount'
          @strategy = :rdiscount
        else
          raise("Your Ichiban project contains at least one Markdown file. To process it, " +
                "you need to gem install one of: rpeg-multimarkdown redcarpet maruku rdiscount.")
        end
        @markdown_loaded = true
      end
    end
  end
end