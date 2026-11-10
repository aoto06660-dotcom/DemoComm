class ProjectMembership < ApplicationRecord
  belongs_to :user
  belongs_to :project

  enum :status, {
    pending: 0,
    accepted: 1
  }

  validates :user_id, uniqueness: { scope: :project_id }

  def remove_with_contributions!
    ProjectMembership.transaction do
      project.audio_versions
             .where(uploaded_by: user)
             .find_each(&:destroy!)
      
      Comment.joins(:audio_version)
             .where(user: user)
             .where(audio_versions: { project_id: project.id })
             .find_each(&:destroy!)

      destroy!
    end
  end
end
