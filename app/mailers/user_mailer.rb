class UserMailer < ApplicationMailer

 #view app/view/user_mailer/confirmation_email
 def confirmation_email(user) #user_controllerのcreateから新規user登録のメール認証メソッド
  #  @user = user
  #  @url = confirm_url(token: @user.confirmation_token)
  #  mail(to: @user.email, subject: "【〇〇サイト】メールアドレスの確認")

   @user = user
   @url  = "http://example.com/login"
   mail(to: @user.email, subject: "私の素敵なサイトへようこそ")
 end
end