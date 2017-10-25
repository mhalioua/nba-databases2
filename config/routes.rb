Rails.application.routes.draw do
	
  root 'index#home'

  match ':controller(/:action(/:id))', :via => [:get, :post]
end
