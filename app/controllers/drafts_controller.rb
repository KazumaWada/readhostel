class DraftsController < ApplicationController
  before_action :require_login, only: [:index, :edit, :update]


  def index
    @user = User.find_by(slug: params[:slug])
    @microposts = @user.microposts.draft
  end

  def edit
    @user = User.find_by(slug: params[:slug])
    @micropost = @user.microposts.draft.find_by(id: params[:id])
  end

  def update
    @user = User.find_by(slug: params[:slug])
    @micropost = @user.microposts.draft.find_by(id: params[:id])

    if params[:draft]
      @micropost.status = 'draft'
    else
      @micropost.status = 'published'
    end

    if @micropost.update(micropost_params) && @micropost.status == 'published'
      flash[:succeess] = 'nice. its published🎉'
      redirect_to user_path(@user)
    elsif @micropost.update(micropost_params) && @micropost.status == 'draft'
      flash[:succeess] = 'save it as a draft📝'
      redirect_to user_path(@user)
    else 
      flash[:danger] = "cant be empty 😑"
      redirect_to draft_path
  end
end
end

private

def micropost_params
  params.require(:micropost).permit(:content, :status)
end