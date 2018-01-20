Rails.application.routes.draw do
	
  root 'index#home'

  get "index/detail/:id/:injury", to: "index#detail"
  get "index/state/:id/:injury", to: "index#detail"

  match ':controller(/:action(/:id))', :via => [:get, :post]
end
