Rails.application.routes.draw do
  mount StripeEvent::Engine, at: '/webhooks/stripe'

  # User login
  devise_for :users

  # Movies that are protected by subscriptions
  resources :movies

  # Payments/Subscriptions
  resource :card
  resource :pricing, controller: :pricing
  resource :subscription do
    patch :resume
  end
  resources :payments
  resources :charges

  # One time payments
  resources :products do
    resource :purchase
  end

  root 'home#index'
end
