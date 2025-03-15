require 'rails_helper'

RSpec.feature 'Manager - Sidenav', type: :feature do
  let!(:manager) { create(:user, :manager, name: 'The Manager') }

  #--------------------------------------------------------------------------
  # 1. COMPANY PRESENT
  #--------------------------------------------------------------------------
  context 'company present' do
    let!(:company) { create(:company, name: 'Manager Company') }

    #--------------------------------------------------------------------------
    # 1.1 COMPANY CHARTS ON
    #--------------------------------------------------------------------------
    context 'company charts on' do
      before do
        company.update(charts_visible: true)
      end

      #----------------------------------------------------------------------
      # 1.1.1 TEAM PRESENT
      #----------------------------------------------------------------------
      context 'team present' do
        let!(:team) { create(:team, name: 'ManagerTeam', company: company) }

        before do
          manager.update(team: team)
        end

        #--------------------------------------------------------------------
        # 1.1.1.1 TEAM CHARTS ON
        #--------------------------------------------------------------------
        context 'team charts on' do
          before do
            team.update(charts_visible: true)
          end

          let!(:user_a) { create(:user, :user, name: 'RegularUser A', team: team) }
          let!(:item_a) { create(:item, user: user_a, name: 'Item A from RegularUser') }
          let!(:item_manager) { create(:item, user: manager, name: 'Item from Manager') }

          # Вторая команда внутри той же компании
          let!(:team2) { create(:team, name: 'Other Team', company: company, charts_visible: true) }
          let!(:user_b) { create(:user, :user, name: 'User B in other team', team: team2) }
          let!(:item_b) { create(:item, user: user_b, name: 'Item B from other team') }

          before do
            login_as(manager, scope: :user)
            visit my_items_path(locale: :en)
          end

          it 'manager sees entire own team, sees other teams if they are also charts_visible' do
            # 1) ENTIRE COMPANY => названия всех команд
            within('#sidenav') do
              click_link 'Entire Company'
            end
            within('#mainContent') do
              # Должны видеть обе команды
              expect(page).to have_content('ManagerTeam')
              expect(page).to have_content('Other Team')
              # Не видим пользователей/айтемов
              expect(page).to have_no_content('RegularUser A')
              expect(page).to have_no_content('User B in other team')
              expect(page).to have_no_content('Item A from RegularUser')
              expect(page).to have_no_content('Item B from other team')
            end

            # 2) ENTIRE TEAM (моя команда)
            within('#sidenav') do
              click_link 'Entire Team', match: :first
            end
            within('#mainContent') do
              # Менеджер видит всех пользователей своей команды
              expect(page).to have_content('The Manager')
              expect(page).to have_content('RegularUser A')
              # Но не видит айтемов в этом представлении
              expect(page).to have_no_content('Item A from RegularUser')
              expect(page).to have_no_content('Item from Manager')
            end

            # 3) Клик по пользователю своей команды
            within('#sidenav') do
              click_link 'RegularUser A'
            end
            within('#mainContent') do
              # Видим айтемы этого пользователя
              expect(page).to have_content('Item A from RegularUser')
              # Не видим менеджерских айтемов
              expect(page).to have_no_content('Item from Manager')
              # Не видим айтемы других команд
              expect(page).to have_no_content('Item B from other team')
            end
          end
        end

        #--------------------------------------------------------------------
        # 1.1.1.2 TEAM CHARTS OFF
        #--------------------------------------------------------------------
        context 'team charts off' do
          before do
            team.update(charts_visible: false)
          end

          let!(:user_c) { create(:user, :user, name: 'UserC TeamOff', team: team) }
          let!(:item_c) { create(:item, user: user_c, name: 'Item C from TeamOff') }
          let!(:item_m) { create(:item, user: manager, name: 'Item from Manager in OffTeam') }

          before do
            login_as(manager, scope: :user)
            visit my_items_path(locale: :en)
          end

          it 'manager can still see entire team even if team charts is off' do
            # ENTIRE COMPANY
            within('#sidenav') do
              click_link 'Entire Company'
            end
            within('#mainContent') do
              # Должны видеть название своей команды
              expect(page).to have_content('ManagerTeam')
              # Не видим пользователей или айтемов
              expect(page).to have_no_content('UserC TeamOff')
              expect(page).to have_no_content('Item C from TeamOff')
            end

            # ENTIRE TEAM
            within('#sidenav') do
              click_link 'Entire Team'
            end
            within('#mainContent') do
              # Менеджер видит всех пользователей (даже если off)
              expect(page).to have_content('The Manager')
              expect(page).to have_content('UserC TeamOff')
              expect(page).to have_no_content('Item C from TeamOff')
            end

            # Клик по конкретному пользователю
            within('#sidenav') do
              click_link 'UserC TeamOff'
            end
            within('#mainContent') do
              expect(page).to have_content('Item C from TeamOff')
              expect(page).to have_no_content('Item from Manager in OffTeam')
            end
          end
        end
      end

      #----------------------------------------------------------------------
      # 1.1.2 TEAM ABSENT
      #----------------------------------------------------------------------
      context 'team absent' do
        before do
          manager.update(team: nil)
          login_as(manager, scope: :user)
          visit my_items_path(locale: :en)
        end

        it 'manager has no team => sees basically only himself' do
          within('#sidenav') do
            # Нет Entire Team, нет других пользователей
            expect(page).to have_no_content('Entire Team')
            expect(page).to have_no_content('The Manager')
          end
          within('#mainContent') do
            # Может быть, у менеджера есть какие-то собственные айтемы
            # Но никаких команд/пользователей нет
          end
        end
      end
    end

    #--------------------------------------------------------------------------
    # 1.2 COMPANY CHARTS OFF
    #--------------------------------------------------------------------------
    context 'company charts off' do
      before do
        company.update(charts_visible: false)
      end

      #----------------------------------------------------------------------
      # 1.2.1 TEAM PRESENT
      #----------------------------------------------------------------------
      context 'team present' do
        let!(:team) { create(:team, name: 'ManagerTeam OffCompany', company: company) }

        before do
          manager.update(team: team)
        end

        #--------------------------------------------------------------------
        # 1.2.1.1 TEAM CHARTS ON
        #--------------------------------------------------------------------
        context 'team charts on' do
          before do
            team.update(charts_visible: true)
          end

          let!(:user_x) { create(:user, :user, name: 'User X', team: team) }
          let!(:item_x) { create(:item, user: user_x, name: 'Item X from userX') }
          let!(:item_mx) { create(:item, user: manager, name: 'Item from Manager OffCompany') }

          before do
            login_as(manager, scope: :user)
            visit my_items_path(locale: :en)
          end

          it 'company off => manager sees team but no entire company link, sees entire team details' do
            within('#sidenav') do
              expect(page).to have_no_content('Entire Company')
              click_link 'Entire Team'
            end
            within('#mainContent') do
              # Видим всех пользователей команды
              expect(page).to have_content('The Manager')
              expect(page).to have_content('User X')
              expect(page).to have_no_content('Item X from userX')
            end

            within('#sidenav') do
              click_link 'User X'
            end
            within('#mainContent') do
              expect(page).to have_content('Item X from userX')
              expect(page).to have_no_content('Item from Manager OffCompany')
            end
          end
        end

        #--------------------------------------------------------------------
        # 1.2.1.2 TEAM CHARTS OFF
        #--------------------------------------------------------------------
        context 'team charts off' do
          before do
            team.update(charts_visible: false)
          end

          let!(:user_y) { create(:user, :user, name: 'HiddenTeam Y', team: team) }
          let!(:item_y) { create(:item, user: user_y, name: 'Item Y from hiddenTeam') }
          let!(:item_my) { create(:item, user: manager, name: 'Manager hiddenTeam item') }

          before do
            login_as(manager, scope: :user)
            visit my_items_path(locale: :en)
          end

          it 'company off + team off => manager still sees entire team in detail' do
            within('#sidenav') do
              expect(page).to have_no_content('Entire Company')
              click_link 'Entire Team'
            end
            within('#mainContent') do
              # Менеджер видит всех, даже если off
              expect(page).to have_content('The Manager')
              expect(page).to have_content('HiddenTeam Y')
              expect(page).to have_no_content('Item Y from hiddenTeam')
            end

            within('#sidenav') do
              click_link 'HiddenTeam Y'
            end
            within('#mainContent') do
              expect(page).to have_content('Item Y from hiddenTeam')
              expect(page).to have_no_content('Manager hiddenTeam item')
            end
          end
        end
      end

      #----------------------------------------------------------------------
      # 1.2.2 TEAM ABSENT
      #----------------------------------------------------------------------
      context 'team absent' do
        before do
          manager.update(team: nil)
          login_as(manager, scope: :user)
          visit my_items_path(locale: :en)
        end

        it 'manager with no team => no entire company link, sees only self' do
          within('#sidenav') do
            expect(page).to have_no_content('Entire Company')
            expect(page).to have_no_content('Entire Team')
            expect(page).to have_no_content('The Manager')
          end
        end
      end
    end
  end

  #--------------------------------------------------------------------------
  # 2. COMPANY ABSENT
  #--------------------------------------------------------------------------
  context 'company absent' do
    context 'team present' do
      let!(:team) { create(:team, name: 'Orphan ManagerTeam', company: nil) }

      before do
        manager.update(team: team)
      end

      #----------------------------------------------------------------------
      # 2.1.1 TEAM CHARTS ON
      #----------------------------------------------------------------------
      context 'team charts on' do
        before do
          team.update(charts_visible: true)
        end

        let!(:user_z) { create(:user, :user, name: 'UserZ in OrphanTeam', team: team) }
        let!(:item_z) { create(:item, user: user_z, name: 'Item Z in OrphanTeam') }

        before do
          login_as(manager, scope: :user)
          visit my_items_path(locale: :en)
        end

        it 'no company => manager sees entire team (charts on), no entire company link' do
          within('#sidenav') do
            expect(page).to have_no_content('Entire Company')
            click_link 'Entire Team'
          end
          within('#mainContent') do
            expect(page).to have_content('The Manager')
            expect(page).to have_content('UserZ in OrphanTeam')
            expect(page).to have_no_content('Item Z in OrphanTeam')
          end

          within('#sidenav') do
            click_link 'UserZ in OrphanTeam'
          end
          within('#mainContent') do
            expect(page).to have_content('Item Z in OrphanTeam')
          end
        end
      end

      #----------------------------------------------------------------------
      # 2.1.2 TEAM CHARTS OFF
      #----------------------------------------------------------------------
      context 'team charts off' do
        before do
          team.update(charts_visible: false)
        end

        let!(:user_w) { create(:user, :user, name: 'UserW Off OrphanTeam', team: team) }
        let!(:item_w) { create(:item, user: user_w, name: 'Item W for UserW') }

        before do
          login_as(manager, scope: :user)
          visit my_items_path(locale: :en)
        end

        it 'no company, team off => manager sees entire team anyway' do
          within('#sidenav') do
            expect(page).to have_no_content('Entire Company')
            click_link 'Entire Team'
          end
          within('#mainContent') do
            expect(page).to have_content('The Manager')
            expect(page).to have_content('UserW Off OrphanTeam')
            expect(page).to have_no_content('Item W for UserW')
          end

          within('#sidenav') do
            click_link 'UserW Off OrphanTeam'
          end
          within('#mainContent') do
            expect(page).to have_content('Item W for UserW')
          end
        end
      end
    end

    context 'team absent' do
      before do
        manager.update(team: nil)
        login_as(manager, scope: :user)
        visit my_items_path(locale: :en)
      end

      it 'manager with no team, no company => sees only himself' do
        within('#sidenav') do
          expect(page).to have_no_content('Entire Company')
          expect(page).to have_no_content('Entire Team')
          expect(page).to have_no_content('The Manager')
        end
      end
    end
  end
end
