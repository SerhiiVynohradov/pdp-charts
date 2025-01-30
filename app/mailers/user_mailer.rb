class UserMailer < ApplicationMailer
  default from: "no-reply@pdp-charts.com"

  def welcome_email
    @user = params[:user]
    @password = params[:password]

    @team = @user.team
    @company = @team&.company

    mail(to: @user.email, subject: "Welcome to PDP Charts!")
  end

  def manager_promoted_email
    @user = params[:user]
    @team = params[:team]
    @company = @team&.company
    mail(to: @user.email, subject: "You’ve been promoted to Manager!")
  end

  def manager_demoted_email
    @user = params[:user]
    @team = params[:team]
    @company = @team&.company
    mail(to: @user.email, subject: "You are no longer a Manager")
  end
end
