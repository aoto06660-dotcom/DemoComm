Rails.application.routes.draw do
  get "invitations/index"
  get "home/index"
  get "/profile/avatar", to: "profiles#avatar", as: :profile_avatar
  devise_for :users

  resources :projects do
    collection do
      get :mine
    end

    resources :audio_versions, only: [:new, :create] do
      resources :comments, only: [:create, :edit, :update, :destroy]
    end

    resources :project_memberships, only: [:create, :destroy]
  end

  resources :audio_versions, only: [] do
    member do
      get :play
    end
  end

  resource :profile, only:[:show, :edit, :update]

  resources :invitations, only: [:index] do 
    member do
      patch :accept
      delete :reject
    end
  end

  delete "projects/:project_id/leave",
         to: "project_memberships#leave",
         as: :leave_project


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
