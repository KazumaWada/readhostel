class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception 
    helper_method :current_user
    include SessionsHelper #rails7ではhelperに書いたら全てのviewに適応される仕様になっている。他のcontroller同士で使いまわしたい時はこうやって書く

    def current_user#ログイン系は全部ifでcurrent_userを使って条件分岐
        @current_user ||= begin
          if cookies.signed[:user_data]
            user_data = cookies.signed[:user_data]
            User.find_by(slug: user_data["slug"])
          end
        end
    end

    def require_login
        unless current_user
          flash[:danger] = "please login."
          redirect_to login_path
        end
    end

    #404
    unless Rails.env.development?
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::RoutingError, with: :render_not_found
    end

    private

    def logged_in_user
        unless logged_in?
            store_location
            redirect_to login_url
        end
    end

    #404
    def render_not_found
      render 'errors/not_found', status: :not_found
    end
    

end
