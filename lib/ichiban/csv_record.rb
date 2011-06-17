module Ichiban
	class CsvRecord
		def self.all
			load
			@records.collect do |record|
				new(record)
			end
		end
		
		class_attribute :attr_column_order
		
		attr_reader :attributes
		
		class_attribute :csv_file
		
		def initialize(record)
			@attributes = {}
			self.class.attr_column_order.each_with_index do |attr, column_index|
				attributes[attr.to_sym] = record[column_index]
			end
		end
		
		private
		
		def self.load
			if file = csv_file
				unless file.start_with?('/')
					file = File.join(Ichiban.project_root, 'data', 'file')
				end
			else
				file = File.join(Ichiban.project_root, 'data', self.name.underscore.pluralize + '.csv')
			end
			csv = CSV.open(file, 'r')
			attr_columns = []
			@heading_row = csv.shift
			@heading_row.each_with_index do |attr, column_index|
				attr = attr.underscore
				attr_columns << attr
				class_eval %Q(
					def #{attr}
						attributes[:#{attr}]
					end
				)
			end
			self.attr_column_order = attr_columns
			@records = csv.entries
			csv.close
		end
	end
end