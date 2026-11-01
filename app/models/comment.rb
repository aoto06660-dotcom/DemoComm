class Comment < ApplicationRecord
  belongs_to :audio_version
  belongs_to :user

  validates :body, presence: true
end
