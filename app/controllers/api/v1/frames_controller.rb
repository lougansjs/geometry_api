class Api::V1::FramesController < Api::V1::ApplicationController
  before_action :set_frame, only: %i[ show update destroy add_circles ]

  # GET /frames
  # TODO: add a query param to add a detailed response with all circles maybe?
  def index
    @frames = Frame.includes(:circles).all

    render json: @frames, each_serializer: FrameSerializer
  end

  # GET /frames/1
  def show
    metrics = FrameMetrics.new(@frame).calculate
    render json: FrameMetricsSerializer.new(metrics).as_json, status: :ok
  end

  # POST /frames
  def create
    @frame = Frame.new(frame_params)
    @frame.save!

    render json: @frame, status: :created
  rescue ActiveRecord::RecordInvalid
    render json: { errors: @frame.errors.full_messages }, status: :unprocessable_entity
  end

  # POST /frames/1/circles
  def add_circles
    @circles = []
    @errors_by_circle = {}

    circles_params.each_with_index do |circle_params, index|
      circle = @frame.circles.build(circle_params)
      if circle.valid?
        circle.save!
        @circles << circle
      else
        @errors_by_circle[index] = circle.errors.full_messages
      end
    end

    if @errors_by_circle.any?
      render json: { errors: format_errors_by_circle }, status: :unprocessable_entity
    else
      render json: @circles, each_serializer: CircleSerializer, status: :created
    end
  rescue StandardError => e
    render json: { error: "Unexpected error: #{e.message}" }, status: :internal_server_error
  end

  # PATCH/PUT /frames/1
  def update
    @frame.update!(frame_params)

    render json: @frame, serializer: FrameSerializer
  rescue ActiveRecord::RecordInvalid
    render json: @frame.errors, status: :unprocessable_entity
  end

  # DELETE /frames/1
  def destroy
    @frame.destroy!

    head :no_content
  rescue ActiveRecord::RecordNotDestroyed
    render json: { errors: @frame.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def set_frame
    @frame = Frame.find(params.expect(:id))
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Frame not found" }, status: :not_found
  end

  def frame_params
    params.require(:frame).permit(
      :width, :height, :center_x, :center_y,
      circles_attributes: [ :diameter, :center_x, :center_y ]
    )
  end

  def circles_params
    params.require(:circles).map do |circle|
      circle.permit(:diameter, :center_x, :center_y)
    end
  end

  def format_errors_by_circle
    @errors_by_circle.map do |circle_index, errors|
      {
        "circle_#{circle_index + 1}": errors
      }
    end
  end
end
