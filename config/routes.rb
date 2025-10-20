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
  post 'reflection/generate_summary', to: 'dashboard#generate_ai_summary', as: :generate_ai_summary
  delete 'reflection/clear_summary', to: 'dashboard#clear_ai_summary', as: :clear_ai_summary
  
  # Posts (失敗ログ)
  resources :posts do
    member do
      post :request_ai_evaluation
      get :edit_reflection_checklist
      patch :update_reflection_checklist
    end
    collection do
      get :search
    end
  end
  
  # Reminders (振り返り)
  resources :reminders, only: [:index, :show, :update] do
    member do
      post :complete
      post :skip
      get :incomplete_feedback
    end
  end
  
  # Reflection Items (チェック項目)
  resources :reflection_items, only: [:create, :update, :destroy] do
    member do
      post :toggle_check
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