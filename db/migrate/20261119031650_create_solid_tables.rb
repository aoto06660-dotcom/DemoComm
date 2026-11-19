class CreateSolidTables < ActiveRecord::Migration[8.1]
  def change
    create_table :solid_tables do |t|
      t.timestamps
    end
  end
end
