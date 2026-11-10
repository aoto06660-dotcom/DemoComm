class Project < ApplicationRecord
  belongs_to :user
  has_many :audio_versions, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :members,
           through: :project_memberships,
           source: :user

  enum :visibility, {
    private: 0,
    public: 1
  }, prefix: true

  validates :title, presence: true

#権限判定method#
  def owner?(user)
    user.present? && user_id == user.id
  end

  def accepted_member?(user)
    return false if user.nil?
    
    project_memberships.accepted.exists?(user_id: user.id)
  end

  def accessible_by?(user)
    visibility_public? || owner?(user) || accepted_member?(user)
  end

  def uploadable_by?(user)
    owner?(user) || accepted_member?(user)
  end

end
