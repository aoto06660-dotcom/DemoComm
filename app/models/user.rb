class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :projects, dependent: :destroy
  has_many :uploaded_audio_versions,
           class_name: "AudioVersion",
           foreign_key: :uploaded_by_id,
           inverse_of: :uploaded_by,
           dependent: :destroy
  has_many :comments, dependent: :destroy

  has_one_attached :avatar

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false }
  validates :bio, length: { maximum: 500 }, allow_blank: true
  validate :avatar_validation

  private

  def avatar_validation
    return unless avatar.attached?

    allowed_types = %w[image/jpeg image/png image/webp]

    unless allowed_types.include?(avatar.blob.content_type)
      errors.add(:avatar, "はJPEG, PNG, WebP形式にしてください")
    end
    
    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "は5MB以下にしてください")
    end
  end
end


