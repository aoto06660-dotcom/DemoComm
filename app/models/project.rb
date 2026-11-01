class Project < ApplicationRecord
  belongs_to :user

  has_many :audio_versions, dependent: :destroy

  validates :title, presence: true
end
