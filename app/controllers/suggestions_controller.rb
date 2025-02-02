class SuggestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_superadmin, except: %i[ new create ]
  before_action :set_suggestion, only: %i[ show edit update destroy ]

  def index
    @suggestions = Suggestion.all
  end

  def show
  end

  def new
    @suggestion = Suggestion.new
  end

  def edit
  end

  def create
    @suggestion = Suggestion.new(suggestion_params)
    @suggestion.user = current_user

    respond_to do |format|
      if @suggestion.save
        path_to_redirect_to = current_user.superadmin? ? suggestions_path : root_path

        format.html { redirect_to path_to_redirect_to, notice: "Suggestion was successfully created." }
        format.json { render :show, status: :created, location: @suggestion }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @suggestion.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @suggestion.update(suggestion_params)
        format.html { redirect_to @suggestion, notice: "Suggestion was successfully updated." }
        format.json { render :show, status: :ok, location: @suggestion }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @suggestion.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @suggestion.destroy!

    respond_to do |format|
      format.html { redirect_to suggestions_path, status: :see_other, notice: "Suggestion was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  def set_suggestion
    @suggestion = Suggestion.find(params[:id])
  end

  def suggestion_params
    params.require(:suggestion).permit(:title, :description)
  end

  def require_superadmin
    redirect_to root_path, alert: "You are not authorized to access this page." unless current_user.superadmin?
  end
end
