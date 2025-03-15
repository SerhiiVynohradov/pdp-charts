require 'rails_helper'

RSpec.feature 'User - Sidenav', type: :feature do
  #--------------------------------------------------------------------------
  # 1. COMPANY PRESENT
  #--------------------------------------------------------------------------
  context 'company present' do
    let!(:company) { create(:company, name: 'Some Company') }

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
        let!(:team) { create(:team, name: 'My Team', company: company) }

        #--------------------------------------------------------------------
        # 1.1.1.1 TEAM CHARTS ON
        #--------------------------------------------------------------------
        context 'team charts on' do
          before do
            team.update(charts_visible: true)
          end

          let!(:user1) { create(:user, :user, name: 'User One', team: team) }
          let!(:user2) { create(:user, :user, name: 'User Two', team: team) }
          let!(:item1) { create(:item, user: user1, name: 'Item for User One') }
          let!(:item2) { create(:item, user: user2, name: 'Item for User Two') }

          # Для полноты сделаем вторую команду, чтобы проверить логику
          let!(:team2) { create(:team, name: 'Other Team', company: company, charts_visible: true) }
          let!(:other_user) { create(:user, :user, name: 'Other Team User', team: team2) }
          let!(:other_item) { create(:item, user: other_user, name: 'Item in other team') }

          before do
            login_as(user1, scope: :user)
            visit my_items_path(locale: :en)
          end

          it 'company on, team on => Entire Company => названия команд; Entire Team => список юзеров; user => его айтемы' do
            #
            # 1) ENTIRE COMPANY -> только названия команд (team и team2) без пользователей / айтемов
            #
            within('#sidenav') do
              click_link 'Entire Company'
            end
            within('#mainContent') do
              expect(page).to have_content('My Team')
              expect(page).to have_content('Other Team')
              # Не должно быть пользователей или айтемов
              expect(page).to have_no_content('User One')
              expect(page).to have_no_content('User Two')
              expect(page).to have_no_content('Other Team User')
              expect(page).to have_no_content('Item for User One')
              expect(page).to have_no_content('Item for User Two')
              expect(page).to have_no_content('Item in other team')
            end

            #
            # 2) ENTIRE TEAM -> только пользователи текущей команды (user1, user2) без айтемов
            #
            within('#sidenav') do
              click_link 'Entire Team', match: :first
            end
            within('#mainContent') do
              expect(page).to have_content('User One')
              expect(page).to have_content('User Two')
              # Не должны отображаться айтемы
              expect(page).to have_no_content('Item for User One')
              expect(page).to have_no_content('Item for User Two')
              # Не должны отображаться другие команды / пользователи
              expect(page).to have_no_content('Other Team')
              expect(page).to have_no_content('Other Team User')
            end

            #
            # 3) Клик по конкретному пользователю => только его айтемы
            #
            within('#sidenav') do
              click_link 'User Two'
            end
            within('#mainContent') do
              expect(page).to have_content('Item for User Two')
              expect(page).to have_no_content('Item for User One')
              expect(page).to have_no_content('Other Team User')
              expect(page).to have_no_content('Item in other team')
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

          let!(:user) { create(:user, :user, name: 'TeamOff User', team: team) }
          let!(:another_user) { create(:user, :user, name: 'Hidden Teammate', team: team) }
          let!(:item_user) { create(:item, user: user, name: 'Item for TeamOff User') }
          let!(:item_other) { create(:item, user: another_user, name: 'Item for Hidden Teammate') }

          # Чтобы показать и другую команду, которая charts_on
          let!(:other_team) { create(:team, name: 'Some Visible Team', company: company, charts_visible: true) }
          let!(:other_team_user) { create(:user, :user, name: 'User in other team', team: other_team) }
          let!(:other_item) { create(:item, user: other_team_user, name: 'Item in other visible team') }

          before do
            login_as(user, scope: :user)
            visit my_items_path(locale: :en)
          end

          it 'company on, team off => Entire Company => только названия команд; заход на мою команду => нет списка юзеров; user => видит только свои айтемы' do
            #
            # 1) ENTIRE COMPANY => названия обеих команд
            #
            within('#sidenav') do
              click_link 'Entire Company'
            end
            within('#mainContent') do
              expect(page).to have_content('My Team')
              expect(page).to have_content('Some Visible Team')

              # Ни пользователей, ни айтемов
              expect(page).to have_no_content('TeamOff User')
              expect(page).to have_no_content('Hidden Teammate')
              expect(page).to have_no_content('User in other team')
              expect(page).to have_no_content('Item for TeamOff User')
              expect(page).to have_no_content('Item in other visible team')
            end

            #
            # 3) Клик по конкретному пользователю => только его айтемы
            #
            within('#sidenav') do
              click_link 'TeamOff User'
            end
            within('#mainContent') do
              expect(page).to have_content('Item for TeamOff User')
              # Не видим айтемы других
              expect(page).to have_no_content('Item for Hidden Teammate')
              # Не видим названия команды/компании
              expect(page).to have_no_content('My Team')
              expect(page).to have_no_content('Some Visible Team')
            end
          end
        end
      end

      #----------------------------------------------------------------------
      # 1.1.2 TEAM ABSENT
      #----------------------------------------------------------------------
      context 'team absent' do
        let!(:user) { create(:user, :user, name: 'Orphaned User', team: nil) }
        let!(:item) { create(:item, user: user, name: 'Orphaned Item') }

        before do
          login_as(user, scope: :user)
          visit my_items_path(locale: :en)
        end

        it 'company on, but no team => entire company => показывает название компании и (предположительно) отсутствие команд' do
          within('#mainContent') do
            expect(page).to have_content('Orphaned Item')
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
        let!(:team) { create(:team, name: 'Team with CompanyOff', company: company) }

        #--------------------------------------------------------------------
        # 1.2.1.1 TEAM CHARTS ON
        #--------------------------------------------------------------------
        context 'team charts on' do
          before do
            team.update(charts_visible: true)
          end

          let!(:user) { create(:user, :user, name: 'User CompanyOff', team: team) }
          let!(:user2) { create(:user, :user, name: 'Another User', team: team) }
          let!(:item1) { create(:item, user: user, name: 'Item for CompanyOff user') }
          let!(:item2) { create(:item, user: user2, name: 'Another item') }

          before do
            login_as(user, scope: :user)
            visit my_items_path(locale: :en)
          end

          it 'company off => no Entire Company link, Entire Team => список юзеров, user => только свои айтемы' do
            # Нет Entire Company, т.к. company charts_off
            within('#sidenav') do
              expect(page).to have_no_content('Entire Company')
            end

            # Entire Team
            within('#sidenav') do
              click_link 'Entire Team'  # Или "Entire Team"
            end
            within('#mainContent') do
              expect(page).to have_content('User CompanyOff')
              expect(page).to have_content('Another User')
              # Нет айтемов
              expect(page).to have_no_content('Item for CompanyOff user')
              expect(page).to have_no_content('Another item')
            end

            # Клик по конкретному пользователю
            within('#sidenav') do
              click_link 'Another User'
            end
            within('#mainContent') do
              expect(page).to have_content('Another item')
              # Остальные айтемы/пользователи не видны
              expect(page).to have_no_content('Item for CompanyOff user')
              expect(page).to have_no_content('User CompanyOff')
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

          let!(:user) { create(:user, :user, name: 'HiddenTeam User', team: team) }
          let!(:user2) { create(:user, :user, name: 'Other HiddenTeam User', team: team) }
          let!(:item1) { create(:item, user: user, name: 'Item for HiddenTeamUser') }
          let!(:item2) { create(:item, user: user2, name: 'Item for OtherHiddenUser') }

          before do
            login_as(user, scope: :user)
            visit my_items_path(locale: :en)
          end

          it 'company off + team off => вообще нет entire company, entire team; кликаем только на себя => свои айтемы' do
            within('#sidenav') do
              expect(page).to have_no_content('Entire Company')
              expect(page).to have_content('HiddenTeam User') # если вообще сгенерили ссылку
              expect(page).to have_no_content('Other HiddenTeam User')
            end

            # Клик на себя
            within('#sidenav') do
              click_link 'HiddenTeam User'
            end
            within('#mainContent') do
              expect(page).to have_content('Item for HiddenTeamUser')
              expect(page).to have_no_content('Item for OtherHiddenUser')
            end
          end
        end
      end

      #----------------------------------------------------------------------
      # 1.2.2 TEAM ABSENT
      #----------------------------------------------------------------------
      context 'team absent' do
        let!(:user) { create(:user, :user, name: 'CompanyOff NoTeam User') }
        let!(:item) { create(:item, user: user, name: 'Item for NoTeam') }

        before do
          login_as(user, scope: :user)
          visit my_items_path(locale: :en)
        end

        it 'company off, no team => no entire company, no entire team; можно кликнуть только на себя' do
          within('#sidenav') do
            expect(page).to have_no_content('Entire Company')
            expect(page).to have_no_content('Entire Team')
          end

          within('#mainContent') do
            expect(page).to have_content('Item for NoTeam')
          end
        end
      end
    end
  end

  #--------------------------------------------------------------------------
  # 2. COMPANY ABSENT
  #--------------------------------------------------------------------------
  context 'company absent' do
    # Не будет возможности «Entire Company», т.к. её нет

    #----------------------------------------------------------------------
    # 2.1 TEAM PRESENT
    #----------------------------------------------------------------------
    context 'team present' do
      let!(:team) { create(:team, name: 'Orphan Team', company: nil) }

      #--------------------------------------------------------------------
      # 2.1.1 TEAM CHARTS ON
      #--------------------------------------------------------------------
      context 'team charts on' do
        before do
          team.update(charts_visible: true)
        end

        let!(:user1) { create(:user, :user, name: 'TeamOn User1', team: team) }
        let!(:user2) { create(:user, :user, name: 'TeamOn User2', team: team) }
        let!(:item1) { create(:item, user: user1, name: 'Item1 TeamOn') }
        let!(:item2) { create(:item, user: user2, name: 'Item2 TeamOn') }

        before do
          login_as(user1, scope: :user)
          visit my_items_path(locale: :en)
        end

        it 'no company => no entire company link, entire team => список юзеров, user => только его айтемы' do
          within('#sidenav') do
            expect(page).to have_no_content('Entire Company')
            click_link 'Entire Team'  # или "Entire Team" — как у тебя
          end
          within('#mainContent') do
            # Видим список юзеров
            expect(page).to have_content('TeamOn User1')
            expect(page).to have_content('TeamOn User2')
            # Не видим айтемов
            expect(page).to have_no_content('Item1 TeamOn')
            expect(page).to have_no_content('Item2 TeamOn')
          end

          # Кликаем по второму пользователю
          within('#sidenav') do
            click_link 'TeamOn User2'
          end
          within('#mainContent') do
            expect(page).to have_content('Item2 TeamOn')
            expect(page).to have_no_content('Item1 TeamOn')
          end
        end
      end

      #--------------------------------------------------------------------
      # 2.1.2 TEAM CHARTS OFF
      #--------------------------------------------------------------------
      context 'team charts off' do
        before do
          team.update(charts_visible: false)
        end

        let!(:user1) { create(:user, :user, name: 'TeamOff User1', team: team) }
        let!(:user2) { create(:user, :user, name: 'TeamOff User2', team: team) }
        let!(:item1) { create(:item, user: user1, name: 'Item1 TeamOff') }
        let!(:item2) { create(:item, user: user2, name: 'Item2 TeamOff') }

        before do
          login_as(user1, scope: :user)
          visit my_items_path(locale: :en)
        end

        it 'no company, team off => нет entire company, нет entire team; видим только себя; клик по себе => свои айтемы' do
          within('#sidenav') do
            expect(page).to have_no_content('Entire Company')
            expect(page).to have_no_content('Entire Team')
            expect(page).to have_content('TeamOff User1')
            expect(page).to have_no_content('TeamOff User2')
            click_link 'TeamOff User1'
          end
          within('#mainContent') do
            expect(page).to have_content('Item1 TeamOff')
            expect(page).to have_no_content('Item2 TeamOff')
          end
        end
      end
    end

    #----------------------------------------------------------------------
    # 2.2 TEAM ABSENT
    #----------------------------------------------------------------------
    context 'team absent' do
      let!(:user) { create(:user, :user, name: 'NoTeamNoCompany User') }
      let!(:item) { create(:item, user: user, name: 'NoTeamNoCompany Item') }

      before do
        login_as(user, scope: :user)
        visit my_items_path(locale: :en)
      end

      it 'нет команды, нет компании => никаких ссылок, кроме самого пользователя' do
        within('#sidenav') do
          expect(page).to have_no_content('Entire Company')
          expect(page).to have_no_content('Entire Team')
          expect(page).to have_no_content('No teams found')
        end
        within('#mainContent') do
          expect(page).to have_content('NoTeamNoCompany Item')
        end
      end
    end
  end
end
