class AuthConstraint
  def matches?(request)
    email = request.session[:user] ? request.session[:user]["email"] : nil
    email.present? && User.exists?(email: email)
  end
end

Rails.application.routes.draw do
  constraints(AuthConstraint.new) do
    root to: "onboarding_messages#index"
  end

  root to: "sessions#new"

  match "/auth/:provider/callback" => "auth#oauth_callback",  via: [:get]
  match "/slack/handshake"         => "auth#slack_handshake", via: [:post]

  resource  :session, only: [:new, :create, :destroy]
  resources :employees, only: [:new, :create, :index, :edit, :update, :destroy]
  resources :users, only: [:edit, :update, :index]
  resources :sent_messages, only: [:index]
  resources :onboarding_messages, only: [
    :new,
    :create,
    :index,
    :edit,
    :update,
    :destroy,
  ] do
    resources :test_messages, only: [:new, :create]
  end
  resources :quarterly_messages, only: [
    :new,
    :create,
    :index,
    :edit,
    :update,
    :destroy,
  ] do
    resources :test_messages, only: [:new, :create]
  end
  resources :broadcast_messages, only: [:new, :create, :index] do
    resources :send_broadcast_messages, only: [:create]
    resources :test_messages, only: [:new, :create]
  end
end
