class SessionsController < ApplicationController

  def new
    #ここで、認証完了のメッセージを表示する。

    #でも次回から普通にログインする場合は、表示しない。
  end

  def create
    user = User.find_by(name: session_params[:name])
  
    if user.nil?
      flash[:danger] = '👻 ユーザーが見つかりません。'
      redirect_to login_path and return
    end

    unless user.validated?
      flash[:danger] = '未認証のユーザーです。メールをご確認下さいませ。'
      #returnする理由は、ここの条件が終わったら、下のロジックに移ってさらにredirect_to root_pathされてしまい、errorになるから。
      redirect_to login_path and return 
    end

    if !user.authenticate(session_params[:password])
      flash[:danger] = "🧩 パスワードが正しくありません 🧩"
      redirect_to login_path and return
    end

     cookies.signed[:user_data] = {
        value: { user_id: user.id, slug: user.slug },
        httponly: true,
        secure: Rails.env.production?,
        expires: 1.month.from_now#指定しなければ、セッションが終わればcookieがなくなる。
      }



    #initial_cardの作成. initial_cardのカラムを作成したけど、結局必要なかった。
    initial_post = user.microposts.first

    if !initial_post
    initial_card = user.microposts.create(content: "Hello, world!", answer: "こんにちは、世界！", original: "Hello world! this is your own eigopencil site!", tags: "welcome!");#1回きりの必要がある。
    initial_card = user.microposts.create(content: "覚えたい単語やフレーズはここへ！", answer: "日本語訳などがあればここへ！", original: "単語やフレーズを使った例文をここへ書いて定着させよう！", tags: "使い方", initial_card: true);#1回きりの必要がある。
    initial_card.save
    end    
    
    flash[:success] = "ようこそ🎉! #{user.name}さん! さっそく「💳 単語登録」から覚えたい英語を登録してみよう！"
    
    redirect_to root_path
    

    
    
    # user = User.find_by(name: session_params[:name])

    # if user && user.authenticate(session_params[:password])
    #   #current_userメソッドを使えるようにするためにこうやって書いている。
    #   cookies.signed[:user_data] = {
    #                                 value: { user_id: user.id, slug: user.slug },
    #                                 httponly: true,
    #                                 secure: Rails.env.production?
    #   }

    #   #cookies.signed[:user_id] = { value: user.id, httponly: true, secure: Rails.env.production? }
      
    #   flash[:success] = "ようこそ🎉! #{current_user.name}さん。"
    #   redirect_to question_path
    # else
    #   flash[:danger] = user.errors.full_messages.join(", ")
    #   redirect_to login_path 
    # end

  end

  def guest
    user = User.find_or_create_by!(email: 'test@gmail.com') do |user|
      user.name = 'test_user'
      user.password = 'password'
      user.password_confirmation = 'password'
    end
    cookies.signed[:user_data] = {
      value: { user_id: user.id, slug: user.slug },
      httponly: true,
      secure: Rails.env.production?,
      expires: 1.month.from_now#指定しなければ、セッションが終わればcookieがなくなる。
    }
    
    #session[:user_id] = user.id
    flash[:success] = "ようこそ🎉あなたはテストユーザーです"
    redirect_to current_user
  end

  def destroy
    Rails.logger.info "Destroy action called"
    cookies.delete(:user_data)
    #flash[:success] = "successfuly logged out"
    redirect_to root_path
  end
end


private

 def session_params
    params.require(:session).permit(:name, :password)
 end
