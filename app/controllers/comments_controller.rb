class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_audio_version
  before_action :set_comment, only: [:edit, :update, :destroy]

  def create
    @comment = @audio_version.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to project_path(@audio_version.project),
                  notice: "コメントを投稿しました"
    else
      redirect_to project_path(@audio_version.project),
                  alert: "コメントを入力してください"
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to project_path(@project),
                  notice: "コメントを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy!

    redirect_to project_path(@audio_version.project),
                notice: "コメントを削除しました"
  end

  private

  def set_audio_version
    @project = Project.find(params[:project_id])

    unless @project.visibility_public? ||
           @project.user_id == current_user.id
      raise ActiveRecord::RecordNotFound
    end

    @audio_version = @project.audio_versions.find(
      params[:audio_version_id]
    )
  end

  def comment_params
    params.require(:comment).permit(:body, :playback_seconds)
  end

  def set_comment
    @comment = @audio_version.comments.find(params[:id])

    unless @comment.user_id == current_user.id
      raise ActiveRecord::RecordNotFound
    end
  end
end
