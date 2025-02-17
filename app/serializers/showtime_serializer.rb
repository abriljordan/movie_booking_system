class ShowtimeSerializer
  include JSONAPI::Serializer
  attributes :start_time, :end_time
end
