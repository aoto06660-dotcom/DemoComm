class ProjectMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:create, :destroy]
  before_action :set_joined_project, only: [:leave]

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user.nil?
      redirect_to @project, alert: "ユーザーが見つかりません"
      return
    end

    if user == current_user
      redirect_to @project, alert: "自分自身は招待できません"
      return
    end

    membership = @project.project_memberships.new(
      user: user,
      status: :pending
    )

    if membership.save
      redirect_to @project, notice: "招待しました"
    else
      redirect_to @project, alert: membership.errors.full_messages.join(",")
    end
  end

  def destroy
    membership = @project.project_memberships
                         .accepted
                         .find(params[:id])
    
    membership.remove_with_contributions!

    redirect_to project_path(@project), notice: "メンバーを解除しました"
    
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed
      redirect_to project_path(@project), alert: "解除に失敗しました"
  end

  def leave
    membership = @project.project_memberships
                         .accepted
                         .find_by!(user: current_user)

    membership.remove_with_contributions!

    redirect_to projects_path, notice: "プロジェクトから退出しました"
  
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed
    redirect_to project_path(@project), alert: "退出に失敗しました"
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_joined_project
    @project = Project.find(params[:project_id])

    unless @project.accepted_member?(current_user)
      raise ActiveRecord::RecordNotFound
    end
  end
end
