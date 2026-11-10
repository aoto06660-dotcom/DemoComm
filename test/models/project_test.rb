require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  setup do
    @owner = User.create!(
      name: "オーナー",
      email: "owner_test@example.com",
      password: "password123"
    )

    @member = User.create!(
      name: "メンバー",
      email: "member_test@example.com",
      password: "password123"
    )

    @outsider = User.create!(
      name: "未参加ユーザー",
      email: "outsider_test@example.com",
      password: "password123"
    )

    @project = @owner.projects.create!(
      title: "テストプロジェクト",
      visibility: :private
    )
  end

  test "所有者を正しく判定できる" do
    assert @project.owner?(@owner)
    assert_not @project.owner?(@member)
    assert_not @project.owner?(nil)
  end

  test "承認済みメンバーを正しく判定できる" do
    @project.project_memberships.create!(
      user: @member,
      status: :accepted
    )

    assert @project.accepted_member?(@member)
    assert_not @project.accepted_member?(@outsider)
  end

  test "承認待ちメンバーは承認済みとして扱われない" do
    @project.project_memberships.create!(
      user: @member,
      status: :pending
    )

    assert_not @project.accepted_member?(@member)
  end

  test "非公開プロジェクトは所有者と承認済みメンバーだけが閲覧できる" do
    @project.project_memberships.create!(
      user: @member,
      status: :accepted
    )

    assert @project.accessible_by?(@owner)
    assert @project.accessible_by?(@member)
    assert_not @project.accessible_by?(@outsider)
    assert_not @project.accessible_by?(nil)
  end

  test "公開プロジェクトは未ログインでも閲覧できる" do
    @project.update!(visibility: :public)

    assert @project.accessible_by?(nil)
    assert @project.accessible_by?(@outsider)
  end

  test "音源アップロードは所有者と承認済みメンバーだけに許可される" do
    @project.project_memberships.create!(
      user: @member,
      status: :accepted
    )

    assert @project.uploadable_by?(@owner)
    assert @project.uploadable_by?(@member)
    assert_not @project.uploadable_by?(@outsider)
    assert_not @project.uploadable_by?(nil)
  end

  test "タイトルが空のプロジェクトは保存できない" do
    @project.title = ""

    assert_not @project.valid?
  end
end