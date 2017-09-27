Rails.application.routes.draw do
  resources :feeds do
    member do
     resources :entries, only: [:index, :show]
    end
  end

  resources :feeds
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  
  root 'feeds#index'

end
