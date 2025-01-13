module My
  class SettingsController < ApplicationController
    before_action :authenticate_user!

    def edit
      @user = current_user
    end

    def update
      @user = current_user
      if @user.update(user_params)
        redirect_to edit_my_settings_path, notice: "Your settings have been updated."
      else
        render :edit
      end
    end

    private

    def user_params
      permitted = params.require(:user).permit(:email, :name, :password, :password_confirmation)
      if permitted[:password].blank?
        permitted.delete(:password)
        permitted.delete(:password_confirmation)
      end
      permitted
    end
  end
end
