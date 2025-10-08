class Api::V1::CirclesController < Api::V1::ApplicationController
  before_action :set_circle, only: %i[ show update destroy ]

  # GET /circles
  def index
    validate_and_convert_search_params!

    @circles = Circle.all
    @circles = @circles.where("frame_id = ?", params[:frame_id]) if params[:frame_id].present?

    @filtered_circles = filter_by_radius

    raise ActiveRecord::RecordNotFound if @filtered_circles.empty?

    render json: @filtered_circles
  rescue ActiveRecord::RecordNotFound
    render json: { error: "No circles found" }, status: :not_found
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  end

  # GET /circles/1
  def show
    render json: @circle
  end

  # PATCH/PUT /circles/1
  def update
    @circle.update!(circle_update_params)

    render json: @circle
  rescue ActiveRecord::RecordInvalid
    render json: format_errors(@circle), status: :unprocessable_entity
  end

  def format_errors(record)
    # "center_x cannot be null", etc.
    record.errors.map { |e| "#{e.attribute} #{e.message}" }
  end

  # DELETE /circles/1
  def destroy
    @circle.destroy!

    head :no_content
  rescue ActiveRecord::RecordNotDestroyed
    render json: { errors: @circle.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def set_circle
    @circle = Circle.find(params.expect(:id))
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Circle not found" }, status: :not_found
  end

  def circle_params
    params.expect(circle: [ :center_x, :center_y ])
  end

  def circle_update_params
    params.expect(circle: [ :center_x, :center_y ])
  end

  def validate_and_convert_search_params!
    unless search_params_present?
      missing_params = []
      missing_params << "center_x" if params[:center_x].blank?
      missing_params << "center_y" if params[:center_y].blank?
      missing_params << "radius" if params[:radius].blank?

      raise ArgumentError, "Missing required search parameters: #{missing_params.join(', ')}"
    end

    raise ArgumentError, "center_x must be a valid number" if params[:center_x].to_s.strip.empty? || !valid_number?(params[:center_x])
    raise ArgumentError, "center_y must be a valid number" if params[:center_y].to_s.strip.empty? || !valid_number?(params[:center_y])
    raise ArgumentError, "radius must be a valid number" if params[:radius].to_s.strip.empty? || !valid_number?(params[:radius])

    @center_x = params[:center_x].to_f
    @center_y = params[:center_y].to_f
    @radius = params[:radius].to_f

    raise ArgumentError, "center_x must be a positive number" if @center_x < 0
    raise ArgumentError, "center_y must be a positive number" if @center_y < 0
    raise ArgumentError, "radius must be a positive number" if @radius <= 0
  end

  def search_params_present?
    params[:center_x].present? &&
    params[:center_y].present? &&
    params[:radius].present?
  end

  def filter_by_radius
    @circles.select do |circle|
      GeometryValidation.new.circle_within_radius?(
        circle, { center_x: @center_x, center_y: @center_y, radius: @radius }
      )
    end
  end

  private

  def valid_number?(value)
    return false if value.nil?

    str_value = value.to_s.strip

    str_value.match?(/\A-?\d+(\.\d+)?([eE][+-]?\d+)?\z/)
  end
end
