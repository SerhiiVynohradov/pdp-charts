Rails.application.routes.draw do
  devise_for :users

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA Routes
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root Path
  root "home#index"

  # My Namespace
  namespace :my do
    resources :items do
      member do
        get :chart
      end
      resources :item_progress_columns, only: [:new, :create, :edit, :update, :destroy] do
        resources :progress_updates, only: [:create, :update, :destroy]
      end
    end
    root to: "items#index"
  end

  # Manager Namespace
  namespace :manager do
    resources :teams, only: [:show, :edit, :update], module: 'teams' do
      member do
        get :charts
        get :settings
        get :recommended
        patch :pause_user, to: 'teams#pause_user'
        get :generate_meeting, to: 'teams#generate_meeting'
        get :external_calendar, to: 'teams#external_calendar'
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
          resources :item_progress_columns, only: [:new, :create, :edit, :update, :destroy] do
            resources :progress_updates, only: [:create, :update, :destroy]
          end
        end
      end
    end
    root to: "dashboards#index"
  end

  # CompanyOwner Namespace
  namespace :company_owner do
    resources :companies, only: [:show], module: 'companies' do
      resources :teams, module: 'teams' do
        member do
          patch :toggle_status
          get :members

          get :charts
          get :settings
          get :recommended
          patch :pause_user, to: 'teams#pause_user'
          get :generate_meeting, to: 'teams#generate_meeting'
          get :external_calendar, to: 'teams#external_calendar'
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
            resources :item_progress_columns, only: [:new, :create, :edit, :update, :destroy] do
              resources :progress_updates, only: [:create, :update, :destroy]
            end
          end
        end
      end
    end

    root to: "dashboards#index"
  end

  # Superadmin Namespace
  namespace :superadmin do
    resources :payers, only: [:index, :show] do
      resources :invoices, only: [:index, :show]
    end
    resources :pricing, only: [:index, :update]

    resources :companies, module: 'companies' do
      member do
        patch :toggle_status
        get :settings
      end

      resources :teams, module: 'teams' do
        member do
          patch :toggle_status
          get :members

          get :charts
          get :settings
          get :recommended
          patch :pause_user, to: 'teams#pause_user'
          get :generate_meeting, to: 'teams#generate_meeting'
          get :external_calendar, to: 'teams#external_calendar'
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
            resources :item_progress_columns, only: [:new, :create, :edit, :update, :destroy] do
              resources :progress_updates, only: [:create, :update, :destroy]
            end
          end
        end
      end
    end

    root to: "dashboards#index"
  end
end
