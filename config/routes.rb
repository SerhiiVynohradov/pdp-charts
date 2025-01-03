Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  # 1) The "User / My" interface (already done)
  namespace :my do
    # Items
    resources :items do
      member do
        get :chart
      end
    end
    # charts, settings, etc.  e.g. get :charts, on: :collection
    root to: "items#index"  # or some dashboard
  end

  # 2) Manager interface -> Team-level
  # e.g. /manager/teams/ :id => manager can see his team
  namespace :manager do
    resources :teams, only: [:show, :edit, :update], module: 'teams' do
      member do
        get :charts
        get :settings
        get :recommended
        patch :pause_user, to: 'teams#pause_user' # for pausing a user
        get :generate_meeting, to: 'teams#generate_meeting' # generate Google Meet link
        get :external_calendar, to: 'teams#external_calendar' # integrate with external calendar
      end

      resources :users, only: [:index, :new, :create, :edit, :update, :destroy] do
        member do
          patch :pause
          get :generate_meeting
          get :external_calendar
        end
      end
    end
    root to: "dashboards#index"
  end

  # 3) Company Owner interface
  namespace :company do
    # The company's main routes
    resource :dashboard, only: [:show]
    resources :teams, only: [:index, :create, :update, :destroy] do
      member do
        get :details
        get :settings
        get :recommended
        # ...
      end
    end
    resources :company_events, only: [:index, :create, :update, :destroy]

    get :charts, to: "dashboards#charts"
    # etc.

    root to: "dashboards#show"
  end

  # 4) Superadmin interface
  namespace :superadmin do
    resources :companies, only: [:index, :create, :update, :destroy] do
      member do
        get :settings
      end
    end
    get :all_companies_chart, to: "dashboards#all_companies_chart"
    resources :payers, only: [:index, :show] do
      resources :invoices, only: [:index, :show]
    end
    resources :pricing, only: [:index, :update]
    root to: "dashboards#index"
  end

  # You might have a root path:
  root "home#index"
end
