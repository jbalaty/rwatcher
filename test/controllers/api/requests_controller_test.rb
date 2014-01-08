require 'test_helper'

class API::RequestsControllerTest < ActionController::TestCase
  setup do
    #@controller = AP I::RequestsController.new
    @myrequest = requests(:one)
  end

  #test "should get index" do
  #  get :index
  #  assert_response :success
  #  assert_not_nil assigns(:requests)
  #end
  #
  #test "should get new" do
  #  get :new
  #  assert_response :success
  #end

  test "should create request" do
    assert_difference('Request.count') do
      post :create, format: :json, request: { title: @myrequest.title, url: @myrequest.url, email:@myrequest.email }
    end

    #assert_redirected_to request_path(assigns(:request))
  end

  #test "should show request" do
  #  get :show, id: @request
  #  assert_response :success
  #end
  #
  #test "should get edit" do
  #  get :edit, id: @request
  #  assert_response :success
  #end
  #
  #test "should update request" do
  #  patch :update, id: @request, request: { title: @request.title, url: @request.url }
  #  assert_redirected_to request_path(assigns(:request))
  #end
  #
  #test "should destroy request" do
  #  assert_difference('Request.count', -1) do
  #    delete :destroy, id: @request
  #  end
  #
  #  assert_redirected_to requests_path
  #end
end
