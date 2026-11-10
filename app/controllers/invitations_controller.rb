class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invitation, only: [:accept, :reject]

  def index
    @invitations = current_user.project_memberships.pending.includes(project: :user)
  end

  def accept
    if @invitation.update(status: :accepted)
      redirect_to invitations_path, notice: "招待を承認しました"
    else
      redirect_to invitations_path, notice: "招待の承認に失敗しました"
    end
  end

  def reject
    if @invitation.destroy
      redirect_to invitations_path, notice: "招待を拒否しました"
    else
      recirect_to invitations_path, alert: "招待の拒否に失敗しました"
    end
  end

  private

  def set_invitation
    @invitation = current_user.project_memberships.pending.find(params[:id])
  end
end
