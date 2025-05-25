module SessionsHelper
    #sessionは元々railsに備え付けのメソッド
    #https://guides.rubyonrails.org/v4.1/action_controller_overview.html#session
    
    #ログインに成功したら、有効期限を保つためにuser.idを暗号化して保持しておく。
    #↓
    #ログアウト、ブラウザが消えたらdestroyでsessionを終了するように書く。
    def log_in(user)#cookieと違い、これはブラウザを閉じた瞬間に有効期限が終了する。
        #schmaで定義はしていないが、active recordが勝手に定義しといてくれている。主キー
        session[:user_id] = user.id#railsのsession機能によってuser.idが暗号化される
    end

    #ログイン情報をcookieに保存して、次回以降もログインを可能にする。
    def remember
        user.remember
        #cookieをそのままではなく、signedで暗号化して渡す。
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end
    #router.rbに定義していなくても、<%= link_to "Write", current_user %>のように使える。
    # def current_user
    #     #session,cookieが発行済み
    #     if(user_id = session[:user_id])
    #         #userをDBから見つけて来る
    #         @current_user ||= User.find_by(id: user_id)
    #     #初回ログインcookie発行
    #     elsif (user_id = cookies.signed[:user_id])
    #      user = User.find_by(id: user_id)
    #      #cookie発行
    #      if user&& user.authenticated?(cookies[:remember_token])
    #         log_in user
    #         @current_user = user
    #      end
    #     end
    #  end

    def logged_in?
        !current_user.nil?
    end
   

    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end 

    def log_out
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end
end
