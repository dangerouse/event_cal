App3211::Application.routes.draw do
  resources :my_calendar do
    collection do
      get ':year/:month/:date' => 'my_calendar#show'
    end
  end

  root :to => 'my_calendar#index'
end
