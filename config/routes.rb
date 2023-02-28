Rails.application.routes.draw do
  mount StripeEvent::Engine, at: '/webhooks/stripe'

  resources :movies
  root 'home#index'
  devise_for :users

  resources :products do
    resource :purchase
  end

  resource :card
  resource :pricing, controller: "pricing"
  resource :subscription, controller: "subscriptions" do
    patch :resume
  end
  resources :payments
  resources :charges
end
