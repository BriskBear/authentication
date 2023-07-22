Rails.application.routes.draw do
  root   'static_pages#home'
  post   'sign_up', to: 'users#create'
  put    'account', to: 'users#update'
  get    'sign_up', to: 'users#new'
  get    'account', to: 'users#edit'
  delete 'account', to: 'users#destroy'

  resources :confirmations, only: %i[create edit new],        param: :confirmation_token
  resources :passwords,     only: %i[create edit new update], param: :password_reset_token

  post   'login',  to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get    'login',  to: 'sessions#new'
end
