module Superadmin
  class CategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :require_superadmin!
    before_action :set_category, only: [:show, :edit, :update, :destroy]

    def index
      @categories = Category.all
    end

    def new
      @category = Category.new
    end

    def show

    end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to superadmin_categories_path, notice: I18n.t('messages.category.created_successfully')
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @category.update(category_params)
        redirect_to superadmin_categories_path, notice: I18n.t('messages.category.updated_successfully')
      else
        render :edit
      end
    end

    def destroy
      @category.destroy
      redirect_to superadmin_categories_path, notice: I18n.t('messages.category.deleted_successfully')
    end

    private

    def category_params
      params.require(:category).permit(:name, :description)
    end

    def require_superadmin!
      redirect_to root_path unless current_user&.superadmin?
    end

    def set_category
      @category = Category.find(params[:id])
    end
  end
end
