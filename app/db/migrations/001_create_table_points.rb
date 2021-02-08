# frozen_string_literal: true

# This runs DB migration - creates a points table with id and point column
# Index will speed up the search
Sequel.migration do
  up do
    create_table :points do
      primary_key :id
      column(:point, 'geography(POINT)')
      index :point, type: :gist
    end
  end

  down do
    drop_table :points
  end
end
