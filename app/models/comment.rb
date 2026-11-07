class Comment < ApplicationRecord
  belongs_to :audio_version
  belongs_to :user

  validates :body, presence: true

  validates :playback_seconds,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            },
            allow_nil: true
end
