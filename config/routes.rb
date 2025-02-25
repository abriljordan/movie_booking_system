Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # User routes (self-management)
      resources :users, only: %i[show create update destroy] do
        resources :bookings, only: %i[index create show update destroy] # User-specific bookings
      end

      # Booking routes
      resources :bookings, only: [ :index ] # Admin: View all bookings

      # Showtime management
      resources :showtimes, only: %i[index show create update destroy]

      # Public movie and theater routes
      resources :movies, only: %i[index show] do
        collection do
          get :search # Public movie search
          post :search
        end
      end

      resources :theaters, only: %i[index show]

      # Admin routes
      namespace :admin do
        # Admin movie management
        resources :movies, only: %i[index create update destroy] do
          member { patch :restore }
          collection {
            get :search
            post :search
          } # Admin-specific movie search
        end

        # Admin theater and showtime management
        resources :theaters, only: %i[create update destroy]
        resources :showtimes, only: %i[create update destroy]

        # Admin booking management
        resources :bookings, only: %i[index create update destroy] do
          member { patch :restore }
          collection {
            get :search
            post :search
          } # Admin-specific booking search
        end
      end

      # Authentication
      resources :tokens, only: [ :create ]
    end
  end
end
