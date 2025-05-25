Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#about" #was home#index
  get '/blog', to: 'home#blog', as: 'blog'
  get '/feature', to: 'home#feature', as: 'feature'
  get '/signup', to: 'users#new', as: 'signup'
  post '/signup', to: 'users#create'
  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create', as: 'login_with_cookie'
  delete '/logout', to: 'sessions#destroy', as: 'logout'
  get '/app', to: 'home#app', as: 'app'
  get '/welcome', to: 'home#welcome', as: 'welcome'
  post '/ocr/recognize', to: 'ocr#recognize'
  resources :sessions, only: [:create]#paramsで見つけられるように。
  get 'tutorial', to: 'home#tutorial', as: 'tutorial'
  post 'guest_login', to: 'sessions#guest', as: 'guest_login'
  get '/books', to: "home#books", as: 'books'
 
  scope '/books' do
    get '/the_brave_little_sparrow', to: "home#the_brave_little_sparrow", as: 'the-brave_little_sparrow'
    get '/the_journey_to_the_hidden_valley', to: "home#the_journey_to_the_hidden_valley", as: 'the_journey_to_the_hidden_valley'
    get '/the_shadow_of_eldoria', to: "home#the_shadow_of_eldoria", as: 'the_shadow_of_eldoria'
    get '/the_eternal_labyrinth', to: "home#the_eternal_labyrinth", as: 'the_eternal_labyrinth'
  end


  # Mailgun
  get 'messages/send_mail', to: 'messages#send_mail'
  # ユーザー仮登録
  get 'pre_signup', to: 'users#pre_signup'


  get '/how_i_use', to: "home#how_i_use", as: 'how_i_use'
  get '/scientific_evidence', to: "home#scientific_evidence", as: 'evidence'
  get '/birth-story', to: "home#birth", as: 'birth'
  #📸
  post 'handwriting/analyze', to: 'users#analyze', as: 'analyze_handwriting'#文字認識機能
  resources :microposts, only: [:index]#slugで先に影響されないように。/micropostsは危ないから。
  resources :users, only: [:index]
  
  #frieendly_id
  get '/:slug', to: 'users#show', as: :user, constraints: { slug: /[a-zA-Z0-9\-_]+/ }#たまにidを読み込もうとするから。
  #.com/user.name/posts/1
  scope '/:slug' do
    #📸
    get '/camera', to: 'users#camera', as: 'camera'
    get '/flashcards', to: 'users#flashcards', as: 'flashcards'
    get '/done_quiz', to: 'users#done_quiz', as: 'done_quiz'
    get '/quiz', to: 'users#quiz_correct_num_edit', as: 'quiz' 
    patch '/quiz_correct_num_update', to: 'users#quiz_correct_num_update', as: 'quiz_correct_num_update'
    get 'drafts/index', to: 'drafts#index', as: 'draft'
    get 'drafts/:id/edit', to: 'drafts#edit', as: 'draft_edit'
    patch 'drafts/:id/update', to: 'drafts#update', as: 'draft_update'
    get 'post/:id/edit', to: 'microposts#edit', as: "edit_micropost"
    patch 'post/:id/update', to: 'microposts#update', as: "update_micropost"
    get 'bookmark', to: 'microposts#bookmark', as: 'bookmark'
    
    #get 'draft', to: 'microposts#draft', as: 'draft'
    get '/post/:id', to: 'microposts#show', as: 'post'
    post '/post/:id', to:'microposts#generate_dynamic_ogp', as: 'generate_dynamic_ogp'
    get '/posts/:tags', to: 'microposts#tags', as: 'tag'
    get 'zen', to: 'microposts#zen_new', as: 'zen' #zen_path(slug: 'example-slug')
    post '/zen_create', to: 'microposts#zen_create', as: 'zen_create'
    #post送信用のurl
    #post '/zen/microposts', to: 'microposts#create', as: :zen_microposts
    resources :microposts, only: [:create, :destroy, :new] #, path: 'posts'    
  end
  
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



