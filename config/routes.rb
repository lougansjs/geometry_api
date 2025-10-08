Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :circles
      resources :frames do
        post "circles", to: "frames#add_circles", on: :member
      end
    end
  end

  # Swagger documentation routes
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  root "pages#index"
end
