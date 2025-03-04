Rails.application.routes.draw do
  resources :suggestions
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA Routes
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root Path
  root "home#index"
  get 'privacy_policy', to: 'home#privacy_policy'
  get "tutorials", to: "home#tutorials"

  resource :plans, only: [] do
    get :upgrade, to: 'plans#upgrade'
    patch :update_role, to: 'plans#update_role'
  end

  resources :teams, only: [:new, :create]
  resources :companies, only: [:new, :create]

  # My Namespace
  namespace :my do
    resources :events, module: 'events'
    resources :recommended_items, only: [:index]
    resource :settings, only: [:edit, :update]
    resources :items, module: 'items' do
      resources :item_progress_columns, only: [], module: 'item_progress_columns' do
        resources :progress_updates, only: [:create, :update, :destroy], module: 'progress_updates'
      end
    end
    resources :item_progress_columns, only: [:new, :create, :edit, :update, :destroy]

    resources :teams, only: [:show], module: 'teams' do
      resources :events, only: [:index, :show], module: 'events'
      resources :users, only: [:index, :show], module: 'users' do
        resources :events, only: [:index, :show], module: 'events'
        resources :items, only: [:index, :show], module: 'items'
      end
    end

    resources :companies, only: [:show], module: 'companies' do
      resources :events, only: [:index, :show], module: 'events'
      resources :teams, only: [:index, :show], module: 'teams' do
        resources :events, only: [:index, :show], module: 'events'
        resources :users, only: [:index, :show], module: 'users' do
          resources :items, only: [:index, :show], module: 'items'
        end
      end
    end

    root to: "items#index"
  end

  # Manager Namespace
  namespace :manager do
    resources :teams, only: [:show, :edit, :update], module: 'teams' do
      resources :events, module: 'events'

      member do
        get :charts
        get :settings
        get :recommended
        patch :pause_user, to: 'teams#pause_user'
        get :generate_meeting, to: 'teams#generate_meeting'
        get :external_calendar, to: 'teams#external_calendar'
      end

      resources :recommended_items, only: [:index, :create, :update, :destroy, :show]

      resources :users, only: [:index, :new, :create, :edit, :update, :destroy, :show], module: 'users' do
        resources :events, module: 'events'

        resources :recommended_items, only: [:index]
        resources :item_progress_columns, only: [:new, :create, :edit, :update, :destroy]

        member do
          patch :pause
          get :generate_meeting
          get :external_calendar
        end

        resources :items, only: [:index, :create, :update, :destroy, :show], module: 'items' do
          resources :item_progress_columns, only: [], module: 'item_progress_columns' do
            resources :progress_updates, only: [:create, :update, :destroy], module: 'progress_updates'
          end
          member do
            patch :pause
            post :recommend
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
    resources :companies, only: [:show, :edit, :update], module: 'companies' do
      resources :events, module: 'events'
      resources :recommended_items, only: [:index, :create, :update, :destroy, :show]

      resources :teams, module: 'teams' do
        resources :events, module: 'events'

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
          resources :events, module: 'events'

          resources :recommended_items, only: [:index]
          resources :item_progress_columns, only: [:new, :create, :edit, :update, :destroy]

          member do
            patch :deactivate
            get :profile

            patch :pause
            patch :make_manager
            get :generate_meeting
            get :external_calendar
          end

          resources :items, only: [:index, :create, :update, :destroy, :show], module: 'items' do
            resources :item_progress_columns, only: [], module: 'item_progress_columns' do
              resources :progress_updates, only: [:create, :update, :destroy], module: 'progress_updates'
            end
            member do
              patch :archive
              post :recommend
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
    resources :events, module: 'events'
    resources :categories
    resources :recommended_items, only: [:index, :create, :update, :destroy, :show]

    resources :payers, only: [:index, :show] do
      resources :invoices
    end

    resources :pricing, only: [:index, :update]

    resources :companies, module: 'companies' do
      resources :events, module: 'events'

      member do
        patch :toggle_status
        get :settings
      end

      resources :teams, module: 'teams' do
        resources :events, module: 'events'

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
          resources :events, module: 'events'
          resources :recommended_items, only: [:index]
          resources :item_progress_columns, only: [:new, :create, :edit, :update, :destroy]

          member do
            patch :deactivate
            get :profile

            patch :make_manager
            patch :pause
            get :generate_meeting
            get :external_calendar
          end

          resources :items, only: [:index, :create, :update, :destroy, :show], module: 'items' do
            resources :item_progress_columns, only: [], module: 'item_progress_columns' do
              resources :progress_updates, only: [:create, :update, :destroy], module: 'progress_updates'
            end
            member do
              patch :archive
              post :recommend
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
