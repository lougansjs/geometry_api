class FramesController < ApplicationController
  before_action :set_frame, only: %i[ show update destroy ]

  # GET /frames
  def index
    @frames = Frame.all

    render json: @frames
  end

  # GET /frames/1
  def show
    render json: @frame
  end

  # POST /frames
  def create
    @frame = Frame.new(frame_params)

    if @frame.save
      render json: @frame, status: :created, location: @frame
    else
      render json: @frame.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /frames/1
  def update
    if @frame.update(frame_params)
      render json: @frame
    else
      render json: @frame.errors, status: :unprocessable_content
    end
  end

  # DELETE /frames/1
  def destroy
    @frame.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_frame
      @frame = Frame.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def frame_params
      params.expect(frame: [ :width, :height, :center_x, :center_y ])
    end
end
