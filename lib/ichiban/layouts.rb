module Ichiban
	module Layouts
		def wrap_in_layouts(erb_context, html)
			erb_context.layout_stack.reverse.inject(html) do |html, layout_name|
				layout_path = Path.new(layout_name + '.html', 'layouts')
				ErbPage.new(File.read(layout_path.abs), :filename => layout_path.abs).evaluate(erb_context) { html }
			end
		end
	end
end