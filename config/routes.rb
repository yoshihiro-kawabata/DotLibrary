Rails.application.routes.draw do
  root 'users#mypage'

  resources :sessions, only: [:new, :create, :destroy]

  resources :comments

  resources :orders do
    collection do
      get 'history'
      get 'talk'
      get 'choice'
      get 'search'
      post 'make'
    end
  end

  resources :books do
    collection do
      get 'search'
    end
  end


  resources :users do
    collection do
      get 'mypage'
    end
  end

  resources :messages do
    collection do
      get 'alldel'
      get 'allshow'
    end
  end


end
