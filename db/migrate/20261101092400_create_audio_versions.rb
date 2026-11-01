class CreateAudioVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :audio_versions do |t|
      t.references :project, null: false, foreign_key: true
      t.integer :version_number
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :audio_versions,
              [:project_id, :version_number],
              unique: true
  end
end
