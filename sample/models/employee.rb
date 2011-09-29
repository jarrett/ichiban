class Employee
	def self.all
		CSV.read(File.join(Ichiban.project_root, 'data', 'employees.csv')).collect do |row|
			new(row[0], row[1])
		end
	end
	
	attr_accessor :first
	
	def initialize(first, last)
		@first = first
		@last = last
	end
	
	attr_accessor :last
end