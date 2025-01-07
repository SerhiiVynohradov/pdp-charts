module CompanyOwner
  module Companies
    module Teams
      module Users
        module Items
          module ItemProgressColumns
            module ProgressUpdates
              class ProgressUpdatesController < ApplicationController
                before_action :authenticate_user!
                before_action :set_company
                before_action :authorize_manage_company!
                before_action :set_team
                before_action :authorize_manage_team!

                include ProgressUpdateManagement

                private
                def set_user
                  @user = @team.users.find(params[:user_id])
                end

                def set_company
                  @company = Company.find(params[:company_id])
                end

                def authorize_manage_company!
                  redirect_to root_path unless can?(:manage, @company)
                end

                def set_team
                  @team = @company.teams.find(params[:team_id])
                end

                def authorize_manage_team!
                  redirect_to root_path unless can?(:manage, @team)
                end
              end
            end
          end
        end
      end
    end
  end
end
