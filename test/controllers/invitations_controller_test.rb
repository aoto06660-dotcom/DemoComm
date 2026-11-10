require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get invitations_url
    assert_response :success
  end
end
