class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :reject_guest, only: [:edit, :update]
  before_action :set_user, only: [:show, :edit, :update]

  def show
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to profile_path, notice: "プロフィールを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def comment_author
    @project = Project.find(params[:project_id])
    raise ActiveRecord::RecordNotFound unless @project.accessible_by?(current_user)

    @audio_version = @project.audio_versions.find(params[:audio_version_id])
    @author = @audio_version.comments.find(params[:id]).user
  end

  def avatar
    user = current_user
    
    return head :not_found unless user.avatar.attached?

    send_data user.avatar.download,
              type: user.avatar.blob.content_type,
              disposition: "inline"
  end

  private
  
  def reject_guest
    head :forbidden if current_user.guest?
  end

  def profile_params
    params.require(:user).permit(:name, :bio, :avatar)
  end

  def set_user
    @user = current_user
  end

end
