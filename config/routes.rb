Rails.application.routes.draw do
  devise_for :users

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
end