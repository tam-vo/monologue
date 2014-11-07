class Monologue::Admin::CategoriesController < Monologue::Admin::BaseController
  respond_to :html
  before_filter :load_category, only: [:show, :edit, :update]

  def index
    @categories = Monologue::Category.all
  end

  def new
    @category = Monologue::Category.new
  end

  def show
    @posts = @category.posts
  end

  def create
    @category = Monologue::Category.new category_params
    if @category.save
      prepare_flash_and_redirect
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      @category.save

      prepare_flash_and_redirect
    else
      render :index
    end
  end

  def destroy
    category = Monologue::Category.find(params[:id])
    if category.destroy
      redirect_to admin_categories_path, notice:  "Removed"
    else
      redirect_to admin_categories_path, alert: "Failed"
    end
  end

private
  def load_category
    @category = Monologue::Category.find(params[:id])
  end

  def prepare_flash_and_redirect
    flash[:notice] =  "Saved"
    # redirect_to edit_admin_category_path(@category)
    redirect_to admin_categories_path
  end

  def category_params
    params.require(:category).permit(:name, :main_post_id)
  end
end
