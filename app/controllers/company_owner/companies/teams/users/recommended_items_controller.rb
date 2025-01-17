module CompanyOwner
  module Companies
    module Teams
      module Users
        class RecommendedItemsController < ApplicationController
          include RecommendedItemsFetching
          before_action :set_context

          private

          def set_context
            redirect_to root_path unless user_signed_in? && current_user.company_owner?

            @company = Company.find(params[:company_id])

            redirect_to root_path unless (can? :manage, @company)

            @team = @company.teams.find(params[:team_id])
            @user = @team.users.find(params[:user_id])
          end
        end
      end
    end
  end
end
