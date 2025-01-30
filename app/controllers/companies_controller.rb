class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_owner_without_company, only: [:new, :create]

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      current_user.update(company_id: @company.id)
      redirect_to company_owner_company_path(@company), notice: "Company created successfully!"
    else
      render :new
    end
  end

  private

  def company_params
    params.require(:company).permit(:name)
  end

  # Проверяем, что current_user - owner и у него нет company
  def ensure_owner_without_company
    unless current_user.company_owner? && current_user.company.nil?
      redirect_to root_path, alert: "You are not allowed to create a company."
    end
  end
end
