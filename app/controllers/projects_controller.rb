class ProjectsController < ApplicationController
  before_action :authenticate_user!,
                only: [:new, :create, :edit, :update, :destroy, :mine]

  before_action :set_owned_project,
                only: [:edit, :update, :destroy]

  def index
    @projects = Project.visibility_public
  end

  def show
    @project = Project.find(params[:id])

    unless @project.accessible_by?(current_user)
      raise ActiveRecord::RecordNotFound
    end

    @audio_versions = @project.audio_versions
                      .includes(comments: :user)
                      .order(version_number: :desc)

    @memberships = @project.project_memberships
                           .accepted
                           .includes(:user)
  end

  def new
    @project = Project.new
  end
  
  def create
    @project = current_user.projects.new(project_params)

    if @project.save
      flash[:show_my_projects_link] = true
      redirect_to projects_path, notice: "プロジェクトを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to project_path(@project), notice: "プロジェクトを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy!
    redirect_to projects_path,
                notice: "プロジェクトを削除しました",
                status: :see_other
  end

  def mine
    @my_projects = current_user.projects.order(created_at: :desc)

    @joined_projects = current_user.joined_projects
                                   .where(project_memberships: { status: :accepted })
                                   .order(created_at: :desc)
  end

  private

  def set_owned_project
    @project = current_user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :visibility)
  end

end