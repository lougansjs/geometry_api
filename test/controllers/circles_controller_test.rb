require "test_helper"

class CirclesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @circle = circles(:one)
  end

  test "should get index" do
    get circles_url, as: :json
    assert_response :success
  end

  test "should create circle" do
    assert_difference("Circle.count") do
      post circles_url, params: { circle: { center_x: @circle.center_x, center_y: @circle.center_y, diameter: @circle.diameter, frame_id: @circle.frame_id } }, as: :json
    end

    assert_response :created
  end

  test "should show circle" do
    get circle_url(@circle), as: :json
    assert_response :success
  end

  test "should update circle" do
    patch circle_url(@circle), params: { circle: { center_x: @circle.center_x, center_y: @circle.center_y, diameter: @circle.diameter, frame_id: @circle.frame_id } }, as: :json
    assert_response :success
  end

  test "should destroy circle" do
    assert_difference("Circle.count", -1) do
      delete circle_url(@circle), as: :json
    end

    assert_response :no_content
  end
end
