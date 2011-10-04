module StaffHelper
  def employee_path(employee)
    "/staff/#{employee.first.downcase}-{employee.last.downcase}/"
  end
end