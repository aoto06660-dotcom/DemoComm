class GuestSessionsController < ApplicationController
  def create
    if user_signed_in?
      redirect_to mine_projects_path, status: :see_other
      return
    end

    guest = User.find_by(email: "guest@email.com", guest: true)
    unless guest
      redirect_to new_user_session_path, alert: "ゲストアカウントは準備中です", status: :see_other
      return
    end

    sign_in(:user, guest)
    redirect_to projects_path, notice: "ゲストとしてログインしました", status: :see_other
  end
end
