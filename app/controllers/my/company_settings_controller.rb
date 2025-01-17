module My
  class SettingsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_context

    def edit
    end

    def update
      if @company.update(company_params)
        redirect_to edit_my_company_settings_path, notice: "Your company settings have been updated."
      else
        render :edit
      end
    end

    private

    def user_params
      params.require(:company).permit(:name, :charts_visible)
    end

    def set_context
      redirect_to root_path unless current_user.company_owner?
      @company = current_user.company
    end
  end
end
