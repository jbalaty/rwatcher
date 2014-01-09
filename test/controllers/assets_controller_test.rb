require 'test_helper'

class AssetsControllerTest < ActionController::TestCase
  test "should get index" do
    get :watch
    assert_response :success
  end

end
