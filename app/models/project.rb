class Project < ApplicationRecord
  belongs_to :user
  has_many :audio_versions, dependent: :destroy

  enum :visibility, {
    private: 0,
    public: 1
  }, prefix: true

  validates :title, presence: true
end
