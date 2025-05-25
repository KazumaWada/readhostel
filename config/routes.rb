Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#index" #was home#index
  get '/blog', to: 'home#blog', as: 'blog'
  get '/feature', to: 'home#feature', as: 'feature'
  get '/signup', to: 'users#new', as: 'signup'
  post '/signup', to: 'users#create'
  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create', as: 'login_with_cookie'
  delete '/logout', to: 'sessions#destroy', as: 'logout'
  get '/app', to: 'home#app', as: 'app'
  get '/welcome', to: 'home#welcome', as: 'welcome'
  resources :sessions, only: [:create]#paramsで見つけられるように。
  get 'tutorial', to: 'home#tutorial', as: 'tutorial'
  post 'guest_login', to: 'sessions#guest', as: 'guest_login'
  get '/books', to: "home#books", as: 'books'



  # Mailgun
  get 'messages/send_mail', to: 'messages#send_mail'
  # ユーザー仮登録
  get 'pre_signup', to: 'users#pre_signup'


  

  
  # Defines the root path route ("/")
  # root "articles#index"
  resources :users, only: [:index, :new, :create, :destroy]
  #get '/profile', to: 'users#show', as: :profile

# # profile配下にpostsをネスト profile/posts/1
#resources :users, only: [:show] do
 #resources :microposts, only: [:create, :destroy, :index] #path: 'posts' (/pathとなる。)
#end
  #resources :microposts, only: [:create, :destroy, :index]#/posts, /posts/1

  
  #delete 'logout'  => 'sessions#destroy'
  #postはuser-viewに存在するからcreateとdestroyのみでok


end



