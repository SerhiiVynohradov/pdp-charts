require 'rails_helper'

RSpec.feature 'CompanyOwner - Sidenav', type: :feature do
  let!(:owner) { create(:user, :company_owner, name: 'The Owner') }

  #--------------------------------------------------------------------------
  # 1. COMPANY PRESENT
  #--------------------------------------------------------------------------
  context 'company present' do
    let!(:company) { create(:company, name: 'Owner Company') }

    before do
      owner.update(company: company)
    end

    #--------------------------------------------------------------------------
    # 1.1 COMPANY CHARTS ON
    #--------------------------------------------------------------------------
    context 'company charts on' do
      before do
        company.update(charts_visible: true)
        login_as(owner, scope: :user)
        visit my_items_path(locale: :en)
      end

      #----------------------------------------------------------------------
      # 1.1.1 TEAM PRESENT
      #----------------------------------------------------------------------
      context 'team present' do
        let!(:team_on)  { create(:team, name: 'TeamOn', company: company, charts_visible: true) }
        let!(:team_off) { create(:team, name: 'TeamOff', company: company, charts_visible: false) }

        let!(:user_on)  { create(:user, :user, name: 'User On',  team: team_on) }
        let!(:item_on)  { create(:item, user: user_on, name: 'Item On') }

        let!(:user_off) { create(:user, :user, name: 'User Off', team: team_off) }
        let!(:item_off) { create(:item, user: user_off, name: 'Item Off') }

        before do
          # reload
          visit current_path
        end

        it 'owner sees entire company, including both on/off teams and all users' do
          # ENTIRE COMPANY
          within('#sidenav') do
            click_link 'Entire Company'
          end
          within('#mainContent') do
            # Видим все команды
            expect(page).to have_content('TeamOn')
            expect(page).to have_content('TeamOff')
            # Не видим пользователей/айтемов (правило: на «странице компании» только названия команд)
            expect(page).to have_no_content('User On')
            expect(page).to have_no_content('User Off')
            expect(page).to have_no_content('Item On')
            expect(page).to have_no_content('Item Off')
          end

          # Клик по TeamOn
          within('#sidenav') do
            page.find_all('a', text: 'Entire Team').last.click
          end
          within('#mainContent') do
            # Видим пользователей этой команды
            expect(page).to have_content('User On')
            expect(page).to have_no_content('User Off')
            # Не видим айтемов
            expect(page).to have_no_content('Item On')
          end

          # Клик по «User On»
          within('#sidenav') do
            click_link 'User On'
          end
          within('#mainContent') do
            expect(page).to have_content('Item On')
            expect(page).to have_no_content('Item Off')
          end

          # Клик по TeamOff
          within('#sidenav') do
            page.find_all('a', text: 'Entire Team').first.click
          end
          within('#mainContent') do
            expect(page).to have_content('User Off')
            expect(page).to have_no_content('User On')
            expect(page).to have_no_content('Item Off')
          end

          # Клик по «User Off»
          within('#sidenav') do
            click_link 'User Off'
          end
          within('#mainContent') do
            expect(page).to have_content('Item Off')
            expect(page).to have_no_content('Item On')
          end
        end
      end

      #----------------------------------------------------------------------
      # 1.1.2 TEAM ABSENT
      #----------------------------------------------------------------------
      context 'team absent' do
        before do
          login_as(owner, scope: :user)
          visit my_items_path(locale: :en)
        end

        it 'owner with company but no teams => entire company shows no teams, still no users' do
          within('#sidenav') do
            click_link 'Entire Company'
          end
          within('#mainContent') do
            # Нет ни одной команды => пусто
            expect(page).to have_content('Owner Company')
            # Можно вывести что «no teams»
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
        login_as(owner, scope: :user)
        visit my_items_path(locale: :en)
      end

      #----------------------------------------------------------------------
      # 1.2.1 TEAM PRESENT
      #----------------------------------------------------------------------
      context 'team present' do
        let!(:team_on)  { create(:team, name: 'TeamOn OffCompany',  company: company, charts_visible: true) }
        let!(:team_off) { create(:team, name: 'TeamOff OffCompany', company: company, charts_visible: false) }

        let!(:user_on)  { create(:user, :user, name: 'User On OffCompany', team: team_on) }
        let!(:item_on)  { create(:item, user: user_on, name: 'Item On OffCompany') }

        let!(:user_off) { create(:user, :user, name: 'User Off OffCompany', team: team_off) }
        let!(:item_off) { create(:item, user: user_off, name: 'Item Off OffCompany') }

        before do
          visit current_path
        end

        it 'owner sees entire company as well, ignoring charts_off' do
          within('#sidenav') do
            click_link 'Entire Company'
          end
          within('#mainContent') do
            expect(page).to have_content('TeamOn OffCompany')
            expect(page).to have_content('TeamOff OffCompany')
            expect(page).to have_no_content('User On OffCompany')
            expect(page).to have_no_content('User Off OffCompany')
          end

          within('#sidenav') do
            page.find_all('a', text: 'Entire Team').last.click
          end
          within('#mainContent') do
            expect(page).to have_content('User On OffCompany')
            expect(page).to have_no_content('User Off OffCompany')
          end

          within('#sidenav') do
            click_link 'User On OffCompany'
          end
          within('#mainContent') do
            expect(page).to have_content('Item On OffCompany')
            expect(page).to have_no_content('Item Off OffCompany')
          end

          within('#sidenav') do
            page.find_all('a', text: 'Entire Team').first.click
          end
          within('#mainContent') do
            expect(page).to have_content('User Off OffCompany')
          end

          within('#sidenav') do
            click_link 'User Off OffCompany'
          end
          within('#mainContent') do
            expect(page).to have_content('Item Off OffCompany')
          end
        end
      end

      #----------------------------------------------------------------------
      # 1.2.2 TEAM ABSENT
      #----------------------------------------------------------------------
      context 'team absent' do
        before do
          login_as(owner, scope: :user)
          visit my_items_path(locale: :en)
        end

        it 'owner with no teams => entire company shows no teams, he has none' do
          within('#sidenav') do
            click_link 'Entire Company'
          end
          within('#mainContent') do
            expect(page).to have_content('Owner Company')
            # Пусто
          end
        end
      end
    end
  end

  #--------------------------------------------------------------------------
  # 2. COMPANY ABSENT
  #--------------------------------------------------------------------------
  context 'company absent' do
    before do
      owner.update(company_id: nil)
      login_as(owner, scope: :user)
      visit my_items_path(locale: :en)
    end

    it 'owner has no company => no entire company link, sees only personal data or no teams' do
      within('#sidenav') do
        expect(page).to have_no_content('Entire Company')
      end
      # Тут можно проверить, что если у него команд нет, он ничего не видит, кроме себя
    end
  end
end
