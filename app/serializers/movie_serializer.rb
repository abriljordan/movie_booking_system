class MovieSerializer
  include JSONAPI::Serializer
  attributes :title, :description, :duration, :rating
end
