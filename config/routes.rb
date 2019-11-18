Rails.application.routes.draw do
	
  root 'index#home'

  get "index/detail/:id/:injury", to: "index#detail"
  get "index/state/:id/:injury", to: "index#state"

  match ':controller(/:action(/:id))', :via => [:get, :post]
end
