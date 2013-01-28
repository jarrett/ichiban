depends_on 'data/employees.json'
depends_on 'html/_employee.html'

JSON.parse(
  File.read(
    File.join(Ichiban.project_root, 'data/employees.json')
  )
)['employees'].each do |employee|
  generate(
    '_employee.html',
    employee['first'].downcase + '-' + employee['last'].downcase + '.html',
    :first => employee['first'],
    :last => employee['last']
  )
end