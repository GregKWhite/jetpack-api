Rails.application.routes.draw do
  resources :projects, only: [:index, :show, :create, :update, :destroy] do
    resources :sprints, only: [:index, :create]
    resources :stories, only: [:index, :create]
    resources :issues,  only: [:index, :create] do
      collection do
        get 'backlog', to:'projects#issue_backlog'
      end
    end
  end

  resources :sprints, only: [:show, :update, :destroy] do
    member do
      post 'activate'
      post 'deactivate'
    end

    resources :stories, only: [:index, :create]
    resources :issues,  only: [:index, :create]
  end

  resources :stories, only: [:show, :update, :destroy] do
    resources :issues,  only: [:index, :create] do
      collection do
        patch 'order'
      end
    end
  end

  resources :issues,  only: [:show, :update, :destroy] do
    member do
      patch 'assignee'
    end

    resources :comments, only: [:index, :create]
  end

  resources :comments, only: [:show, :update, :destroy]

  resources :users do
    collection do
      post 'from_token'
    end
  end

  resource :teams, only: [:show, :create, :destroy]
  resources :users, only: [:index]
  post '/seed', to: 'teams#seed'
end
