Employee.all.each do |employee|
	generate(
		'staff/_employee.html',
		File.join('staff', "#{employee.first.downcase}-#{employee.last.downcase}"),
		:first => employee.first,
		:last => employee.last
	)
end
