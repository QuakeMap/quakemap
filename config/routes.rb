QuakeMap::Application.routes.draw do
  # mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  root to: 'quakes#index'
  get 'recent.:format' => 'quakes#index'
end
