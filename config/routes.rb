Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # Scoped user routes
      resources :users, only: %i[show create update destroy] do
        resources :bookings, only: [ :index, :create, :show, :update, :destroy ] # Added commas
      end

      resources :bookings, only: [ :index ] # Admin can view all bookings

      resources :showtimes, only: %i[index show create update destroy] # Allow full CRUD for admins

      resources :movies, only: %i[index show] # Public-facing routes
      resources :theaters, only: %i[index show] # Public-facing routes
      namespace :admin do
        resources :movies, only: %i[create update destroy] do
          member do
            patch :restore
          end
        end

        resources :theaters, only: %i[create update destroy] # Admin-specific theater routes
        resources :showtimes, only: %i[create update destroy] # Add showtimes for admin
        resources :bookings, only: %i[index create update destroy] do # Add bookings for admin
          member do
            patch :restore
          end
        end
      end

      resources :tokens, only: [ :create ] # Authentication
    end
  end
end
