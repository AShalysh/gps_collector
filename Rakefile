namespace 'db' do
  task :drop do
    require 'sequel'
    require_relative 'app'
    
    # Drop points table and clear schema table
    DB.drop_table(:points)
    DB[:schema_info].delete
  end
end