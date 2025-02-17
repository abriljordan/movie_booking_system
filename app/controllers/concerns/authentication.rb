module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def authenticate_user!
    header = request.headers["Authorization"]
    Rails.logger.debug "Authorization Header: #{header}"  # Debugging line

    return render json: { error: "Unauthorized: Token missing" }, status: :unauthorized unless header.present?

    token = header.split(" ").last
    decoded = JsonWebToken.decode(token)
    Rails.logger.debug "Decoded Payload: #{decoded}"  # Debugging line

    if decoded.present? && decoded[:user_id]
      @current_user = User.find_by(id: decoded[:user_id])
      Rails.logger.debug "Authenticated User: #{@current_user.inspect}"  # Debugging line

      render json: { error: "Unauthorized: User not found" }, status: :unauthorized unless @current_user
    else
      render json: { error: "Unauthorized: Invalid token payload" }, status: :unauthorized
    end
  end

  def authenticate_admin!
    Rails.logger.debug "Current User: #{current_user.inspect}"  # Debugging
    unless current_user&.admin?
      Rails.logger.debug "Access Denied: Not an Admin"  # Debugging
      render json: { error: "Forbidden: Admin access required" }, status: :forbidden
    end
  end

  def current_user
    @current_user
  end
end
