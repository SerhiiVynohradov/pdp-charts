class UserMailer < ApplicationMailer
  default from: "no-reply@pdp-charts.com"

  def welcome_email
    @user = params[:user]
    @password = params[:password]

    @team = @user.team
    @company = @team&.company

    mail(to: @user.email, subject: "Welcome to PDP Charts!")
  end
end
