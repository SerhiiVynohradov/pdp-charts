module My
  class SettingsController < My::BaseController
    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to edit_my_settings_path, notice: I18n.t('messages.settings.saved_successfully')
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
