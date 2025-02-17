module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def authenticate_user!
    header = request.headers["Authorization"]
    return render json: { error: "Unauthorized: Token missing" }, status: :unauthorized unless header.present?

    token = header.split(" ").last

    begin
      decoded = JsonWebToken.decode(token)
    rescue StandardError => e
      Rails.logger.debug "JWT Decode Error: #{e.message}"  # Debugging
      return render json: { error: "Unauthorized: Invalid token" }, status: :unauthorized
    end

    return render json: { error: "Unauthorized: Invalid token payload" }, status: :unauthorized unless decoded.present? && decoded[:user_id]

    @current_user = User.find_by(id: decoded[:user_id])
    render json: { error: "Unauthorized: User not found" }, status: :unauthorized unless @current_user
  end


  def authenticate_admin!
    authenticate_user! # Ensure user is authenticated first

    Rails.logger.debug "Current User: #{@current_user.inspect}"  # Debugging
    render json: { error: "Forbidden: Admin access required" }, status: :forbidden unless @current_user&.admin?
  end

  def current_user
    @current_user
  end
end
