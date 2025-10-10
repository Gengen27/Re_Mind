Rails.application.routes.draw do
  devise_for :users

  # Root path
  root "home#index"

  # Static pages
  get 'home/index'
  get 'dashboard', to: 'dashboard#index'
  get 'analytics', to: 'dashboard#analytics'
  get 'reflection', to: 'dashboard#reflection'
end