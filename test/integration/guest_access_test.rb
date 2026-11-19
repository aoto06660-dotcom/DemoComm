require "test_helper"

class GuestAccessTest < ActionDispatch::IntegrationTest
  setup do
    @guest = User.create!(name: "ゲスト", email: "guest@email.com",
                          password: SecureRandom.urlsafe_base64(32), guest: true)
  end

  test "guest can sign in and create a project" do
    assert_no_difference "User.count" do
      post guest_sign_in_path
    end
    assert_redirected_to projects_path
    follow_redirect!
    assert_response :success

    assert_difference "Project.count", 1 do
      post projects_path, params: { project: { title: "ゲストのデモ", visibility: "private" } }
    end
    assert @guest.projects.exists?(title: "ゲストのデモ")
  end

  test "guest cannot edit settings or change and delete the account directly" do
    post guest_sign_in_path

    get edit_profile_path
    assert_response :forbidden
    patch profile_path, params: { user: { name: "新しい名前" } }
    assert_response :forbidden
    get edit_user_registration_path
    assert_response :forbidden
    patch user_registration_path, params: { user: { email: "new@example.test", password: "new-password" } }
    assert_response :forbidden
    delete user_registration_path
    assert_response :forbidden
    assert_equal "ゲスト", @guest.reload.name
  end
end
