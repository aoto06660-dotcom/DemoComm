class AudioVersion < ApplicationRecord
  belongs_to :project

  belongs_to :uploaded_by,
             class_name: "User",
             inverse_of: :uploaded_audio_versions

  has_many :comments, dependent: :destroy

  has_one_attached :audio_file

  validates :version_number,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: { scope: :project_id }

  validates :audio_file, presence: true

  validate :acceptable_audio_file

  private

  def acceptable_audio_file
    return unless audio_file.attached?

    allowed_types = [
      "audio/mpeg",
      "audio/wav",
      "audio/x-wav",
      "audio/wave"
    ]

    unless allowed_types.include?(audio_file.blob.content_type)
      errors.add(:audio_file, "はMP3またはWAV形式を選択してください")
    end
  end

end
