class HomeController < ApplicationController
  layout false, only: [:about, :blog]

  def index
    #@user = User.find(params[:id])#これはuser/1から取得している。rootだと探せない。
    @user = current_user
    @micropost = current_user.microposts.build if logged_in?
    @microposts = Micropost.all
    #this can handle to "theme99.webp"
    @random_image = "theme%02d.webp" % rand(1..26)

    locations_path = Rails.root.join('config', 'locations.json')
    @locations = JSON.parse(File.read(locations_path))
    #@location = @locations[@random_image] if nill->"Unknow"という書き方になっている。
    @location = @locations.fetch(@random_image, "Unknown")
    
  end

  def show
  end

  def blog
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def app
    @user = current_user#navbarのuser_path(@user)が/appで探せなくなるから。
  end
  def about #THIS IS CURRENT ROOT!
    if current_user
      #redirect_to user_path(slug: current_user.name)こっちでも動作する。
      redirect_to user_path(current_user.name)#/users/#{current_user.name}
    else
      #do nothing 
    end
    
    @user = current_user#navbarのuser_path(@user)が/questionで探せなくなるから。
  end

  def how_i_use
    @user = current_user#navbarのuser_path(@user)が/blogで探せなくなるから。
  end
  def scientific_evidence
    @user = current_user
  end
  def birth
    @user = current_user
  end
  def books
    @user = current_user
  end

  def the_brave_little_sparrow
  end

  def the_journey_to_the_hidden_valley
  end
  def the_shadow_of_eldoria
  end
  def the_eternal_labyrinth
  end
  def welcome
    #application.html.erbの影響を消す。
    render layout: false
    
  end

  def feature
  end

end