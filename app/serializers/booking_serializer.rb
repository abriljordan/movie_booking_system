class BookingSerializer
  include JSONAPI::Serializer
  attributes :seats, :total_price
end
