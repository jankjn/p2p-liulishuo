Rails.application.routes.draw do
  resources :loans, only: [:index, :show, :create] do
    post 'confirm', on: :member
  end
  resources :pay_backs, only: [:index, :show, :create]
  resources :accounts, only: [:index, :show]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
