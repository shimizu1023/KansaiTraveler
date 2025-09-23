Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise
  devise_for :users

  # Users
  resources :users, only: [:show]

  # Root
  root to: "posts#index"

  # Posts and interactions
  resources :posts do
    resources :comments, only: [:create, :destroy]
    resource :like, only: [:create, :destroy]
  end

  # Follow relationships
  resources :relationships, only: [:create, :destroy]

  # Direct messages
  resources :conversations, only: [:index, :show, :create] do
    resources :messages, only: [:create]
  end
end
