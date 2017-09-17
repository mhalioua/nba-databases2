Rails.application.routes.draw do
  get 'welcome/index'
  get "welcome/index(/:id)", to: "welcome#index"

  root 'welcome#index'
end
