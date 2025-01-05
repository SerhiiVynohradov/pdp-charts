module CompanyOwner
  module Companies
    module Teams
      module Users
        module Items
          class ItemsController < ApplicationController
            before_action :authenticate_user!

            before_action :set_company
            before_action :authorize_manage_company!

            before_action :set_team
            before_action :authorize_manage_team!

            include ItemManagement

            private
            def set_company
              @company = Company.find(params[:company_id])
            end

            def authorize_manage_company!
              redirect_to root_path unless (can? :manage, @company)
            end

            def set_team
              @team = @company.teams.find(params[:team_id])
            end

            def authorize_manage_team!
              redirect_to root_path unless (can? :manage, @team)
            end
          end
        end
      end
    end
  end
end
