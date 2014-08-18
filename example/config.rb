Ichiban.config do |cfg|
  cfg.relative_url_root = '/'
  cfg.dependencies = {
    'layouts/default.html' => '*',
    'data/employees.json' => 'scripts/generate_employees.rb',
    '_employee.html' => 'scripts/generate_employees.rb',
  }
end