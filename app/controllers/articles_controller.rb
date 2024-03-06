class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ show update destroy ]
  before_action :authenticate_user!, only: %i[ create update destroy ]
  before_action :check_article_owner, only: %i[ update destroy ]
  before_action :is_private_article, only: %i[ show ]


  # GET /articles
  def index
    if current_user
      @articles = Article.where(is_private: false).or(Article.where(user: current_user))
    else
      @articles = Article.where(is_private: false)
    end
    render json: @articles
  end
  

  # GET /articles/1
  def show
    if current_user && (current_user == @article.user || !@article.is_private)
      render json: @article
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
  

  # POST /articles
  def create
    if current_user
      @article = current_user.articles.new(article_params)
  
      if @article.save
        render json: @article, status: :created, location: @article
      else
        render json: @article.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
  

  # PATCH/PUT /articles/1
  def update
    if @article.update(article_params)
      render json: @article
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  # DELETE /articles/1
  def destroy
    @article.destroy!
    render json: { message: 'Article was successfully destroyed.' }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(:title, :content, :is_private)
    end

  def check_article_owner
    unless @article.user == current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end


  def is_private_article
    unless current_user && @article.is_private == false && @article.user == current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
