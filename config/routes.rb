StripeToFreeagent::Application.routes.draw do

  root "pages#home"

  devise_for :users

  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]

  match "setup_stripe", to: "pages#setup_stripe", via: [:get, :patch, :delete]

end