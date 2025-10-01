require "test_helper"

class FramesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @frame = frames(:one)
  end

  test "should get index" do
    get frames_url, as: :json
    assert_response :success
  end

  test "should create frame" do
    assert_difference("Frame.count") do
      post frames_url, params: { frame: { center_x: @frame.center_x, center_y: @frame.center_y, height: @frame.height, width: @frame.width } }, as: :json
    end

    assert_response :created
  end

  test "should show frame" do
    get frame_url(@frame), as: :json
    assert_response :success
  end

  test "should update frame" do
    patch frame_url(@frame), params: { frame: { center_x: @frame.center_x, center_y: @frame.center_y, height: @frame.height, width: @frame.width } }, as: :json
    assert_response :success
  end

  test "should destroy frame" do
    assert_difference("Frame.count", -1) do
      delete frame_url(@frame), as: :json
    end

    assert_response :no_content
  end
end
