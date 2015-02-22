Rails.application.routes.draw do

  root "pages#home"

  devise_for :users

  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]

  resources :freeagent_accounts
  resources :stripe_accounts
  resources :imports

end