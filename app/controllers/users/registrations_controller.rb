class Users::RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    build_resource(sign_up_params)

    resource.role = "user"

    if (Rails.env.production? && verify_recaptcha(model: resource) && resource.save) ||
       (!Rails.env.production? && resource.save)
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    else
      flash.delete(:recaptcha_error)
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def after_sign_up_path_for(resource)
    upgrade_plans_path
  end
end
