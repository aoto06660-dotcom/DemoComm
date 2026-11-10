require "test_helper"

class ProjectMembershipRemovalTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(
      name: "所有者",
      email: "removal_owner@example.com",
      password: "password123"
    )

    @member = User.create!(
      name: "解除対象メンバー",
      email: "removal_member@example.com",
      password: "password123"
    )

    @other_member = User.create!(
      name: "別のメンバー",
      email: "removal_other@example.com",
      password: "password123"
    )

    @outsider = User.create!(
      name: "未参加ユーザー",
      email: "removal_outsider@example.com",
      password: "password123"
    )

    @pending_user = User.create!(
      name: "承認待ちユーザー",
      email: "removal_pending@example.com",
      password: "password123"
    )

    @project = @owner.projects.create!(
      title: "メンバー解除テスト",
      visibility: :private
    )

    @membership = @project.project_memberships.create!(
      user: @member,
      status: :accepted
    )

    @other_membership = @project.project_memberships.create!(
      user: @other_member,
      status: :accepted
    )

    @project.project_memberships.create!(
      user: @pending_user,
      status: :pending
    )

    @member_audio = @project.audio_versions.create!(
      uploaded_by: @member,
      version_number: 1,
      audio_file: fixture_file_upload(
        "test/fixtures/files/test_audio.mp3",
        "audio/mpeg"
      )
    )

    @other_audio = @project.audio_versions.create!(
      uploaded_by: @other_member,
      version_number: 2,
      audio_file: fixture_file_upload(
        "test/fixtures/files/test_audio.mp3",
        "audio/mpeg"
      )
    )

    @member_comment = @other_audio.comments.create!(
      user: @member,
      body: "解除対象メンバーのコメント"
    )
  end

  test "所有者はメンバーを解除できる" do
    sign_in @owner

    delete project_project_membership_path(
      @project, @membership
    )

    assert_not ProjectMembership.exists?(@membership.id)
    assert_redirected_to project_path(@project)
  end

  test "解除されたメンバーの音源が削除される" do
    sign_in @owner

    delete project_project_membership_path(
      @project, @membership
    )

    assert_not AudioVersion.exists?(@member_audio.id)
  end

  test "解除されたメンバーのコメントが削除される" do
    sign_in @owner

    delete project_project_membership_path(
      @project, @membership
    )

    assert_not Comment.exists?(@member_comment.id)
  end

  test "他のメンバーの音源は残る" do
    sign_in @owner

    delete project_project_membership_path(
      @project, @membership
    )

    assert AudioVersion.exists?(@other_audio.id)
    assert ProjectMembership.exists?(@other_membership.id)
  end

  test "メンバーは自主退出できる" do
    sign_in @member

    delete leave_project_path(@project)

    assert_not ProjectMembership.exists?(@membership.id)
    assert_not AudioVersion.exists?(@member_audio.id)
    assert_not Comment.exists?(@member_comment.id)

    assert_redirected_to projects_path
  end

  test "所有者以外はメンバーを解除できない" do
    sign_in @other_member

    assert_no_difference "ProjectMembership.count" do
      delete project_project_membership_path(
        @project, @membership
      )
    end

    assert_response :not_found
  end

  test "未参加ユーザーは退出できない" do
    sign_in @outsider

    assert_no_difference "ProjectMembership.count" do
      delete leave_project_path(@project)
    end

    assert_response :not_found
  end

  test "承認待ちユーザーは退出できない" do
    sign_in @pending_user

    assert_no_difference "ProjectMembership.count" do
      delete leave_project_path(@project)
    end

    assert_response :not_found
  end
end
