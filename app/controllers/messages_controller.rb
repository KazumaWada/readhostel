class MessagesController < ApplicationController

  #messages/send_mail
  #これはテスト用。同じのがuser_controllerに全て書いてある。
#  def send_mail
#    MailgunService.send_template_email(
#      to: 'Kazuma Wada <kazumawadaa@gmail.com>',
#      subject: 'ようこそ！',
#      template: 'dear new user',
#      variables: { user_name: 'kazuma' }
#    )
#    puts "hey👋 from mailgun"
#   render plain: "メール送信完了"


#  MailgunService.send_template_email(
#   to: 'Kazuma Wada <kazumawadaa@gmail.com>',
#   subject: 'ようこそ！',
#   template: 'dear new user',
#   variables: {
#      "user_name" => @user.name,
#      "confirmation_token" => @user.confirmation_token
#    }
  # )
 end

end
