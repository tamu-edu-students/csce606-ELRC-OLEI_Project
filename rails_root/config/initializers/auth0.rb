# ./config/initializers/auth0.rb
AUTH0_CONFIG = Rails.application.credentials[Rails.env.to_sym] # Rails.env is set in config/environment.rb and can be 'development', 'test', or 'production'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    AUTH0_CONFIG['auth0_client_id'],
    AUTH0_CONFIG['auth0_client_secret'],
    AUTH0_CONFIG['auth0_domain'],
    callback_path: '/auth/auth0/callback',
    authorize_params: {
      scope: 'openid profile'
    }
  )
end
