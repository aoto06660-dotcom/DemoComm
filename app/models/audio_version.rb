class AudioVersion < ApplicationRecord
  belongs_to :project

  belongs_to :uploaded_by,
             class_name: "User",
             inverse_of: :uploaded_audio_versions

  has_many :comments, dependent: :destroy

  validates :version_number,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: { scope: :project_id }
end
