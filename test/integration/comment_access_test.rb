require "test_helper"

class CommentAccessTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(
      name: "所有者",
      email: "comment_owner@example.com",
      password: "password123"
    )

    @member = User.create!(
      name: "メンバー",
      email: "comment_member@example.com",
      password: "password123"
    )

    @outsider = User.create!(
      name: "未参加ユーザー",
      email: "comment_outsider@example.com",
      password: "password123"
    )

    @project = @owner.projects.create!(
      title: "コメントテスト",
      visibility: :private
    )

    @project.project_memberships.create!(
      user: @member,
      status: :accepted
    )

    @audio_version = @project.audio_versions.create!(
      uploaded_by: @owner,
      version_number: 1,
      audio_file: fixture_file_upload(
        "test/fixtures/files/test_audio.mp3",
        "audio/mpeg"
      )
    )

    @comment = @audio_version.comments.create!(
      user: @owner,
      body: "元のコメント"
    )
  end

  test "所有者はコメントを投稿できる" do
    sign_in @owner

    assert_difference "Comment.count", 1 do
      post project_audio_version_comments_path(
        @project, @audio_version
      ), params: {
        comment: { body: "新しいコメント" }
      }
    end
  end

  test "承認済みメンバーはコメントを投稿できる" do
    sign_in @member

    assert_difference "Comment.count", 1 do
      post project_audio_version_comments_path(
        @project, @audio_version
      ), params: {
        comment: { body: "メンバーのコメント" }
      }
    end
  end

  test "未参加ユーザーは非公開プロジェクトにコメントできない" do
    sign_in @outsider

    assert_no_difference "Comment.count" do
      post project_audio_version_comments_path(
        @project, @audio_version
      ), params: {
        comment: { body: "不正なコメント" }
      }
    end

    assert_response :not_found
  end

  test "未ログインではコメントを投稿できない" do
    post project_audio_version_comments_path(
      @project, @audio_version
    ), params: {
      comment: { body: "未ログインのコメント" }
    }

    assert_redirected_to new_user_session_path
  end

  test "投稿者は自分のコメントを更新できる" do
    sign_in @owner

    patch project_audio_version_comment_path(
      @project, @audio_version, @comment
    ), params: {
      comment: { body: "更新したコメント" }
    }

    assert_equal "更新したコメント", @comment.reload.body
  end

  test "他人のコメントは更新できない" do
    sign_in @member

    patch project_audio_version_comment_path(
      @project, @audio_version, @comment
    ), params: {
      comment: { body: "不正な更新" }
    }

    assert_response :not_found
    assert_equal "元のコメント", @comment.reload.body
  end

  test "投稿者は自分のコメントを削除できる" do
    sign_in @owner

    assert_difference "Comment.count", -1 do
      delete project_audio_version_comment_path(
        @project, @audio_version, @comment
      )
    end
  end

  test "他人のコメントは削除できない" do
    sign_in @member

    assert_no_difference "Comment.count" do
      delete project_audio_version_comment_path(
        @project, @audio_version, @comment
      )
    end

    assert_response :not_found
  end
end