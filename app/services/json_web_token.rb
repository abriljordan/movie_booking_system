# services/json_web_token.rb
class JsonWebToken
  SECRET_KEY = Rails.application.credentials.secret_key_base

  def self.encode(payload, exp = 24.hours.from_now)
    raise "Secret key not configured" unless SECRET_KEY

    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode(token)
    return nil unless SECRET_KEY

    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" }).first
    Rails.logger.debug "Decoded JWT Payload: #{decoded.inspect}"
    Rails.logger.debug "Decoded Token: #{decoded}"  # Debugging line

    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature
    Rails.logger.debug "JWT Error: Expired Signature"

    {}
  rescue JWT::DecodeError, JWT::VerificationError
    Rails.logger.debug "JWT Error: Decode Error or Verification Error"

    {}
  end
end
