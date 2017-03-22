Rails.application.routes.draw do
  defaults format: :json do
    resources :loans, only: [:index, :show, :create] do
      post 'confirm', on: :member
    end
    resources :pay_backs, only: [:index, :show, :create]
    resources :accounts, only: [:index, :show, :create]

    post 'sign_up', to: 'accounts#create'
    post 'login', to: 'sessions#create'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
