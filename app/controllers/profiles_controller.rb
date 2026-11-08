class ProfilesController < ApplicationController
  before_action :authenticate_user!
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

  def avatar
    user = current_user
    
    return head :not_found unless user.avatar.attached?

    send_data user.avatar.download,
              type: user.avatar.blob.content_type,
              disposition: "inline"
  end

  private
  
  def profile_params
    params.require(:user).permit(:name, :bio, :avatar)
  end

  def set_user
    @user = current_user
  end

end
