require "test_helper"

class ProjectAccessTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(
      name: "所有者",
      email: "access_owner@example.com",
      password: "password123"
    )

    @member = User.create!(
      name: "参加メンバー",
      email: "access_member@example.com",
      password: "password123"
    )

    @outsider = User.create!(
      name: "未参加ユーザー",
      email: "access_outsider@example.com",
      password: "password123"
    )

    @private_project = @owner.projects.create!(
      title: "非公開プロジェクト",
      visibility: :private
    )

    @public_project = @owner.projects.create!(
      title: "公開プロジェクト",
      visibility: :public
    )

    @private_project.project_memberships.create!(
      user: @member,
      status: :accepted
    )
  end

  test "未ログインでも公開プロジェクトを閲覧できる" do
    get project_path(@public_project)

    assert_response :success
  end

  test "未ログインでは非公開プロジェクトを閲覧できない" do
    get project_path(@private_project)

    assert_response :not_found
  end

  test "所有者は非公開プロジェクトを閲覧できる" do
    sign_in @owner

    get project_path(@private_project)

    assert_response :success
  end

  test "承認済みメンバーは非公開プロジェクトを閲覧できる" do
    sign_in @member

    get project_path(@private_project)

    assert_response :success
  end

  test "未参加ユーザーは非公開プロジェクトを閲覧できない" do
    sign_in @outsider

    get project_path(@private_project)

    assert_response :not_found
  end

  test "所有者はプロジェクト編集画面を開ける" do
    sign_in @owner

    get edit_project_path(@private_project)

    assert_response :success
  end

  test "承認済みメンバーはプロジェクト編集画面を開けない" do
    sign_in @member

    get edit_project_path(@private_project)

    assert_response :not_found
  end

  test "未参加ユーザーはプロジェクトを更新できない" do
    sign_in @outsider

    patch project_path(@private_project), params: {
      project: {
        title: "不正に変更されたタイトル"
      }
    }

    assert_response :not_found
    assert_equal "非公開プロジェクト", @private_project.reload.title
  end

  test "承認済みメンバーはプロジェクトを削除できない" do
    sign_in @member

    assert_no_difference "Project.count" do
      delete project_path(@private_project)
    end

    assert_response :not_found
  end

  test "未ログインではプロジェクト編集画面からログイン画面へ移動する" do
    get edit_project_path(@private_project)

    assert_redirected_to new_user_session_path
  end
end