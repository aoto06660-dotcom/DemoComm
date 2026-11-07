class AddPlaybackSecondsToComments < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :playback_seconds, :integer
  end
end
