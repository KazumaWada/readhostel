class User < ApplicationRecord
    has_many :microposts, dependent: :destroy#userが削除->micropostsも。
    #呼び出されたら、自動的にこれが実行される。(ユーザーがデータを作成してDBに格納する時に自動的に覚えてくれる機能。セッション,cookie)
    attr_accessor :remember_token
    #user.rb: データのロジックを書く時に使われる。(他のmodel, controller,DB)
    #user_helper: 主にviewで使う時に使われる。
    validates :name, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    # validates :password, presence: true, length: { minimum: 6 }


    ##.com/user.name
    extend FriendlyId
    friendly_id :name, use: :slugged

    #self: 現在のuser
    before_save { self.email = email.downcase }
    
    validates :name, presence: true, length: {maximum: 15}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: {maximum: 255}, 
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }#大小文字区別しない

    has_secure_password#(.authenticate, password_digest)
    #allow_nil:trueは、User情報をupdateするときにパスワードを必要としないから 
    #↑新規登録の時は、has_secure_passwordでpasswordが空欄だと引っかかるからok            
    # validates :password, presence: true, length: { minimum: 6 }, allow_nil: true, confirmation: true
    validates :password, length: { minimum: 6 }, confirmation: true, allow_nil: true
    #if->password.present?は、新規登録のtoken認証リンククリックでpasswordは必要ない。その時のため。(passwordが存在したら、presence true)
    validates :password_confirmation, presence: true, if: -> { password.present? }

    #↑
    #passwordをハッシュ化してDBに保存する。(has_secure_passwordによって)
    #DB内のpassword_digestというテーブルを作成しそこに保存するのが決まり(https://railstutorial.jp/chapters/modeling_users?version=4.2#sec-a_hashed_password)
    #password,password_cofirmationとauthenticateというメソッドが使えるようになる。
    #user.authenticate("password")でtrue,falseが実装できる
    # 与えられた文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

    # ランダムなトークンを返す
    def User.new_token
     SecureRandom.urlsafe_base64
    end

    def remember
       #ランダムな文字列をremember_tokenへ保存。
        self.remember_token = User.new_token
        #update_attribute: railsに備わっている機能で、DBの内容を変更するメソッド
        #ユーザーがログインしたらremember_digestにセッションを継続させるためにトークンを格納しておく。そしたら次回からもそのトークンの認証でログインし続けれらる。
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    def authenticate?(remember_token)
        return false if remember_digest.nil?
        BCrypt::password.new(remember_digest).is_password?(remember_token)
    end

    def forget
        update_attribute(:remember_digest, nil)
    end

end

#User.create(name: "Michael Hartl", email: "mhartl@example.com", password: "foobar", password_confirmation: "foobar")