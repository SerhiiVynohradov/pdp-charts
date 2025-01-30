class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # Ваша логика, например, User.from_omniauth(request.env['omniauth.auth'])
    # и далее редирект
  end

  def linkedin
    # Аналогично
  end

  def facebook
    # ...
  end
end
