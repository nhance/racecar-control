require 'sidekiq/web'

Aer::Application.routes.draw do
  use_doorkeeper

  devise_for :drivers, controllers: { registrations: "driver/registrations" }
  devise_for :users

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount Aer::API => '/api', as: 'api'

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
    resources :sms_messages, only: [:new, :create, :destroy] do
      member do
        post :resend
      end
      collection do
        post :clear_pending
      end
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  authenticate :driver do
    resources :teams, only: [:index] do
      post "select", on: :member
    end
    resources :drivers, only: [:show] do
      collection do
        get :autocomplete
      end
    end
    resource :team, except: [:destroy]
    resources :cars
    resources :registrations, only: [:create, :show, :destroy, :update] do
      resources :payments, only: [:create]
      resources :drivers, only: [:index, :create, :destroy], module: 'registrations'
      resources :reservables, only: [:index, :show] do
        resource :reservation, only: [:create, :destroy]
      end
    end
  end

  resources :drivers, only: [:index] do
    member do
      get :barcode
    end
  end

  resources :seasons, only: [] do
    resources :results, only: [:index]
  end

  resources :events, only: [:index] do
    get :teams
    get :stops
    resources :laptimes, only: [:index]
    resources :races, only: [:index]
    resources :results, only: [:index]
    resources :reservables, only: [:index, :show]
    post :registrations

    authenticate :user do
      resources :driver_registrations, only: [:index]
    end
  end

  resources :races, only: [] do
    resources :unknown_drivers, only: [:index]
    resources :results, only: [:index, :create] do
      collection do
        get :grid
        post :grid, action: 'update_grid'
        get :preview
        post :preview, action: 'update_preview'
        post :generate
      end
    end
  end

  resources :scans, only: [:update]

  authenticate :user do
    resources :registrations, only: [] do
      resources :scans, only: [:new]
    end
  end

  resources :scans, only: [:create, :show] do
    post :analyze, on: :member
    post :mock_pit, on: :member
    post :violation, on: :member
  end

  resources :rfid_reads, only: [:create, :index, :show]

  get '/live', to: 'live#show', as: 'live'

  get '/scan/:event/:pit/:car/:driver', :to => 'scan#create'
  post '/scan/:event/:pit/:car/:driver', :to => 'scan#create'

  get '/cars/:id/barcode', :to => 'car#barcode'
  get '/qualifying', :to => 'qualifying#index'

  get '/orbits/export', :to => 'orbits#export'

  post '/rfidtest', to: 'rfidtests#create'

  root to: redirect("/team")
end
