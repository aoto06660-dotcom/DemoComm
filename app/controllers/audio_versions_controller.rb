class AudioVersionsController < ApplicationController
  before_action :authenticate_user!, except: [:play]
  before_action :set_project, except: [:play]

  def new
    @audio_version = @project.audio_versions.new
  end

  def create
    @audio_version = @project.audio_versions.new(audio_project_params)
    @audio_version.uploaded_by = current_user

    saved = false

    @project.with_lock do
      @audio_version.version_number = 
        (@project.audio_versions.maximum(:version_number) || 0) + 1
      
      saved = @audio_version.save
    end

    if saved
      redirect_to project_path(@project),
                  notice: "音源をアップロードしました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def play
    @audio_version = AudioVersion.find(params[:id])
    project = @audio_version.project

    unless project.visibility_public? ||
            (user_signed_in? && project.user_id == current_user.id)
      raise ActiveRecord::RecordNotFound
    end

    unless @audio_version.audio_file.attached?
      raise ActiveRecord::RecordNotFound
    end

    file = @audio_version.audio_file

    send_data file.download,
              type: file.blob.content_type,
              disposition: "inline"
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def audio_project_params
    params.require(:audio_version).permit(:audio_file)
  end

end
