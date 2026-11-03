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

    unless @project.visibility_public? ||
           (user_signed_in? && @project.user_id == current_user.id)
      raise ActiveRecord::RecordNotFound
    end
  end

  def new
    @project = Project.new
  end
  
  def create
    @project = current_user.projects.new(project_params)

    if @project.save
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
    @projects = current_user.projects.order(created_at: :desc)
  end

  private

  def set_owned_project
    @project = current_user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :visibility)
  end

end