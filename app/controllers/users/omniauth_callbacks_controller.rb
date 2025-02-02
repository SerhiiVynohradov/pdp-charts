class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # Ваша логика, например, User.from_omniauth(request.env['omniauth.auth'])
    # и далее редирект
    auth = request.env['omniauth.auth']
    origin = request.env['omniauth.origin']

    user = current_user || User.find_or_initialize_by(email: auth.info.email)

    @new_user = false

    # If this is a new user - get info from google
    if user.new_record?
      @new_user = true
      user.name = auth.info.name
      randompassword = Devise.friendly_token.first(8)
      user.password = randompassword
      user.password_confirmation = randompassword
      user.save!
    end

    user_account = user.user_accounts.find_or_initialize_by(
      provider: auth.provider,
      provider_account_id: auth.uid
    )

    user_account.access_token = auth.credentials.token
    user_account.auth_protocol = 'oauth2'
    user_account.expires_at = Time.zone.at(auth.credentials.expires_at).to_datetime
    user_account.refresh_token = auth.credentials.refresh_token
    user_account.scope = auth.credentials.scope
    user_account.token_type = 'Bearer'

    user_account.save!

    # Login the user if he is not signed in and redirect to his root url
    if !user_signed_in?
      sign_in user
      if @new_user
        flash[:notice] = "Welcome to our site! Your password is #{randompassword}. Please change it in your profile."
        redirect_to upgrade_plans_path
      else
        redirect_to root_url
      end
    else
      redirect_to origin
    end
  end

  def linkedin
    render text: request.env
  end

  def facebook
    # ...
  end
end
