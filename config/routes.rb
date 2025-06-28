Rails.application.routes.draw do
  #Auckland
  get '/a', to: redirect('/') 
  get '/a/ampi_valen', to: 'auckland#ampi_valen', as: :ampi_valen

  # Toronto
  get '/t', to: redirect('/')
  get '/t/brazilian_guy', to: "toronto#brazilian_guy"

  root "home#index" #was home#index
end



