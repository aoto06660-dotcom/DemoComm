
require "test_helper"

class InvitationAccessTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(
      name: "所有者",
      email: "invite_owner@example.com",
      password: "password123"
    )

    @member = User.create!(
      name: "招待対象者",
      email: "invite_member@example.com",
      password: "password123"
    )

    @outsider = User.create!(
      name: "未参加ユーザー",
      email: "invite_outsider@example.com",
      password: "password123"
    )

    @project = @owner.projects.create!(
      title: "招待テスト",
      visibility: :private
    )
  end

  test "所有者はユーザーを招待できる" do
    sign_in @owner

    assert_difference "ProjectMembership.count", 1 do
      post project_project_memberships_path(@project),
           params: { email: @member.email }
    end

    membership = @project.project_memberships.find_by!(
      user: @member
    )

    assert membership.pending?
  end

  test "承認済みメンバーは他人を招待できない" do
    @project.project_memberships.create!(
      user: @member,
      status: :accepted
    )

    sign_in @member

    assert_no_difference "ProjectMembership.count" do
      post project_project_memberships_path(@project),
           params: { email: @outsider.email }
    end

    assert_response :not_found
  end

  test "未参加ユーザーは他人を招待できない" do
    sign_in @outsider

    assert_no_difference "ProjectMembership.count" do
      post project_project_memberships_path(@project),
           params: { email: @member.email }
    end

    assert_response :not_found
  end

  test "所有者は自分自身を招待できない" do
    sign_in @owner

    assert_no_difference "ProjectMembership.count" do
      post project_project_memberships_path(@project),
           params: { email: @owner.email }
    end

    assert_redirected_to project_path(@project)
  end

  test "同じユーザーを重複招待できない" do
    @project.project_memberships.create!(
      user: @member,
      status: :pending
    )

    sign_in @owner

    assert_no_difference "ProjectMembership.count" do
      post project_project_memberships_path(@project),
           params: { email: @member.email }
    end

    assert_redirected_to project_path(@project)
  end

  test "招待された本人は承認できる" do
    invitation = @project.project_memberships.create!(
      user: @member,
      status: :pending
    )

    sign_in @member

    patch accept_invitation_path(invitation)

    assert invitation.reload.accepted?
    assert_redirected_to invitations_path
  end

  test "招待された本人は拒否できる" do
    invitation = @project.project_memberships.create!(
      user: @member,
      status: :pending
    )

    sign_in @member

    assert_difference "ProjectMembership.count", -1 do
      delete reject_invitation_path(invitation)
    end

    assert_not ProjectMembership.exists?(invitation.id)
  end

  test "他人の招待は承認できない" do
    invitation = @project.project_memberships.create!(
      user: @member,
      status: :pending
    )

    sign_in @outsider

    patch accept_invitation_path(invitation)

    assert_response :not_found
    assert invitation.reload.pending?
  end

  test "他人の招待は拒否できない" do
    invitation = @project.project_memberships.create!(
      user: @member,
      status: :pending
    )

    sign_in @outsider

    assert_no_difference "ProjectMembership.count" do
      delete reject_invitation_path(invitation)
    end

    assert_response :not_found
  end

  test "未ログインでは招待を承認できない" do
    invitation = @project.project_memberships.create!(
      user: @member,
      status: :pending
    )

    patch accept_invitation_path(invitation)

    assert_redirected_to new_user_session_path
    assert invitation.reload.pending?
  end
end
