class TheaterSerializer
  include JSONAPI::Serializer
  attributes :name, :location, :total_seats
end
