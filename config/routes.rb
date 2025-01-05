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

      resources :users, only: [:index, :new, :create, :edit, :update, :destroy, :show], module: 'users' do
        member do
          patch :pause
          get :generate_meeting
          get :external_calendar
        end

        resources :items, only: [:index, :create, :update, :destroy, :show], module: 'items' do
          member do
            patch :pause
          end
        end
      end
    end
    root to: "dashboards#index"
  end

  # 3) Company Owner interface

  # Company Namespace (new)
  namespace :company_owner do
    resources :companies, only: [:show], module: 'companies' do
      resources :teams, module: 'teams' do
        member do
          patch :toggle_status
          get :members # For listing team members (users)

          get :charts
          get :settings
          get :recommended
          patch :pause_user, to: 'teams#pause_user' # for pausing a user
          get :generate_meeting, to: 'teams#generate_meeting' # generate Google Meet link
          get :external_calendar, to: 'teams#external_calendar' # integrate with external calendar
        end

        resources :users, only: [:index, :new, :create, :edit, :update, :destroy, :show], module: 'users' do
          member do
            patch :deactivate
            get :profile

            patch :pause
            get :generate_meeting
            get :external_calendar
          end

          resources :items, only: [:index, :create, :update, :destroy, :show], module: 'items' do
            member do
              patch :archive
            end
          end
        end
      end
    end

    root to: "dashboards#index"
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
