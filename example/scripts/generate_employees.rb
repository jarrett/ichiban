depends_on 'data/employees.json'

JSON.parse(
  File.read(
    File.join(Ichiban.project_root, 'data/employees.json')
  )
)['employees'].each do |employee|
  generate(
    '_employee',
    employee['first'] + '-' + employee['last'],
    :first => employee['first']
    :last => employee['last']
  )
end