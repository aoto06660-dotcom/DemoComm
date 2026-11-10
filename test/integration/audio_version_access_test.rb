require "test_helper"

class AudioVersionAccessTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(
      name: "所有者",
      email: "audio_owner@example.com",
      password: "password123"
    )

    @member = User.create!(
      name: "承認済みメンバー",
      email: "audio_member@example.com",
      password: "password123"
    )

    @pending_user = User.create!(
      name: "承認待ちユーザー",
      email: "audio_pending@example.com",
      password: "password123"
    )

    @outsider = User.create!(
      name: "未参加ユーザー",
      email: "audio_outsider@example.com",
      password: "password123"
    )

    @project = @owner.projects.create!(
      title: "非公開音源テスト",
      visibility: :private
    )

    @project.project_memberships.create!(
      user: @member,
      status: :accepted
    )

    @project.project_memberships.create!(
      user: @pending_user,
      status: :pending
    )

    @audio_version = @project.audio_versions.create!(
      uploaded_by: @owner,
      version_number: 1,
      audio_file: fixture_file_upload(
        "test/fixtures/files/test_audio.mp3",
        "audio/mpeg"
      )
    )
  end

  test "所有者は音源アップロード画面を開ける" do
    sign_in @owner

    get new_project_audio_version_path(@project)

    assert_response :success
  end

  test "承認済みメンバーは音源アップロード画面を開ける" do
    sign_in @member

    get new_project_audio_version_path(@project)

    assert_response :success
  end

  test "承認待ちメンバーはアップロード画面を開けない" do
    sign_in @pending_user

    get new_project_audio_version_path(@project)

    assert_response :not_found
  end

  test "未参加ユーザーはアップロード画面を開けない" do
    sign_in @outsider

    get new_project_audio_version_path(@project)

    assert_response :not_found
  end

  test "未ログインではアップロード画面を開けない" do
    get new_project_audio_version_path(@project)

    assert_redirected_to new_user_session_path
  end

  test "未参加ユーザーは音源を投稿できない" do
    sign_in @outsider

    assert_no_difference "AudioVersion.count" do
      post project_audio_versions_path(@project), params: {
        audio_version: {
          audio_file: fixture_file_upload(
            "test/fixtures/files/test_audio.mp3",
            "audio/mpeg"
          )
        }
      }
    end
  
    assert_response :not_found
  end
#音源再生テスト#
  test "所有者は非公開音源を再生できる" do
    sign_in @owner

    get play_audio_version_path(@audio_version)

    assert_response :success
      
    assert_equal(
      @audio_version.audio_file.blob.content_type,
      response.media_type
    )
  end

  test "承認済みメンバーは非公開音源を再生できる" do
    sign_in @member

    get play_audio_version_path(@audio_version)

    assert_response :success
  end

  test "承認待ちメンバーは非公開音源を再生できない" do
    sign_in @pending_user

    get play_audio_version_path(@audio_version)

    assert_response :not_found
  end

  test "未参加ユーザーは非公開音源を再生できない" do
    sign_in @outsider

    get play_audio_version_path(@audio_version)

    assert_response :not_found
  end

  test "未ログインでは非公開音源を再生できない" do
    get play_audio_version_path(@audio_version)

    assert_response :not_found
  end

  test "公開音源は未ログインでも再生できる" do
    @project.update!(visibility: :public)

    get play_audio_version_path(@audio_version)

    assert_response :success
  end
end