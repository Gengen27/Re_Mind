Rails.application.routes.draw do
  # Devise routes for user authentication
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  # Root path
  root "home#index"
  
  # Static pages
  get 'home/index'
  get 'dashboard', to: 'dashboard#index'
  get 'analytics', to: 'dashboard#analytics'
  get 'reflection', to: 'dashboard#reflection'
  
  # Posts (失敗ログ)
  resources :posts do
    member do
      post :request_ai_evaluation
    end
    collection do
      get :search
    end
  end
  
  # Categories
  resources :categories, only: [:index, :show]
  
  # User settings
  resource :settings, only: [:show, :update]
  
  # API endpoints for AJAX
  namespace :api do
    namespace :v1 do
      resources :posts, only: [] do
        member do
          get :score_data
        end
      end
      get 'dashboard/chart_data'
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end