Rails.application.routes.draw do
  root 'sessions#new'

  resources :sessions, only: [:new, :create, :destroy]
  resources :books
  resources :meesages
  resources :orders
  resources :users

end
