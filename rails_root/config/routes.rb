# frozen_string_literal: true

Rails.application.routes.draw do
  resources :survey_questions
  # Defines the root path route ("/")
  root 'home#index'

  get 'home/index'
  get 'about', to: 'about#index'

  resources :survey_responses
  resources :survey_profiles
  resources :invitations, only: %i[show create]

  get '/auth/auth0/callback' => 'auth0#callback'
  get '/auth/failure' => 'auth0#failure'
  get '/auth/logout' => 'auth0#logout'
  # test route for auth0
  get '/auth/test' => 'auth0#test'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
end
