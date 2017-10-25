Rails.application.routes.draw do
	
  root 'index#index'

  match ':controller(/:action(/:id))', :via => [:get, :post]
end
