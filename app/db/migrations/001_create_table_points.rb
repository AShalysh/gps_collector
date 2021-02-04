Sequel.migration do
  up do
    create_table :points do
      primary_key :id
      column(:points, 'geography(POINT)')
      index :points, type: :gist
    end
  end

  down do
    drop_table :points
  end
end