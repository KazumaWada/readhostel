class UserMailerPreview < ActionMailer::Preview
 def confirmation_email
   # user = User.first || User.new(name: "テストユーザー", email: "test@example.com")
   UserMailer.confirmation_email(user)
 end
end

#http://localhost:3000/rails/mailers/user_mailer/confirmation_emailで閲覧可