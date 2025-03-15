require 'rails_helper'

RSpec.feature 'Superadmin - Sidenav', type: :feature do
  let!(:superadmin) { create(:user, :superadmin, name: 'SuperAdmin') }

  before do
    # Создаём несколько компаний c on/off
    @company1 = create(:company, name: 'Company 1', charts_visible: true)
    @company2 = create(:company, name: 'Company 2', charts_visible: false)

    # В каждой компании несколько команд (on/off)
    @team1_on  = create(:team, name: 'Team1 ON',  charts_visible: true,  company: @company1)
    @team1_off = create(:team, name: 'Team1 OFF', charts_visible: false, company: @company1)
    @team2_on  = create(:team, name: 'Team2 ON',  charts_visible: true,  company: @company2)
    @team2_off = create(:team, name: 'Team2 OFF', charts_visible: false, company: @company2)

    # Пользователи в каждой команде
    @user1_on  = create(:user, :user, name: 'User1 ON',  team: @team1_on)
    @user1_off = create(:user, :user, name: 'User1 OFF', team: @team1_off)
    @user2_on  = create(:user, :user, name: 'User2 ON',  team: @team2_on)
    @user2_off = create(:user, :user, name: 'User2 OFF', team: @team2_off)

    # Айтемы
    create(:item, user: @user1_on,  name: 'Item1 ON')
    create(:item, user: @user1_off, name: 'Item1 OFF')
    create(:item, user: @user2_on,  name: 'Item2 ON')
    create(:item, user: @user2_off, name: 'Item2 OFF')

    login_as(superadmin, scope: :user)
    visit my_items_path(locale: :en)
  end

  it 'superadmin sees everything: all companies, all teams, all users, ignoring charts_on/off' do
    # Предположим, в сайдбаре есть какая-то ссылка "All Companies" или мы просто видим список компаний.
    # Для наглядности делаем клики, как в других тестах:

    within('#sidenav') do
      # Суперадмин видит Company 1, Company 2, и т.д.
      expect(page).to have_content('Company 1')
      expect(page).to have_content('Company 2')
      click_link 'Entire Company', match: :first
    end
    within('#mainContent') do
      # Видим и Team1 ON, и Team1 OFF
      expect(page).to have_content('Team1 ON')
      expect(page).to have_content('Team1 OFF')
      # Не видим пользователей в представлении "company" (только названия команд)
      expect(page).to have_no_content('User1 ON')
      expect(page).to have_no_content('User1 OFF')
    end

    within('#sidenav') do
      click_link 'Entire Team', match: :first
    end
    within('#mainContent') do
      # Видим пользователей офф-команды (User1 OFF)
      expect(page).to have_content('User1 OFF')
      # Но не видим айтемов
      expect(page).to have_no_content('Item1 OFF')
    end

    within('#sidenav') do
      click_link 'User1 OFF'
    end
    within('#mainContent') do
      # Видим айтем офф-пользователя
      expect(page).to have_content('Item1 OFF')
    end

    within('#sidenav') do
      page.find_all('a', text: 'Entire Company').last.click
    end
    within('#mainContent') do
      expect(page).to have_content('Team2 ON')
      expect(page).to have_content('Team2 OFF')
      expect(page).to have_no_content('User2 ON')
    end

    within('#sidenav') do
      page.find_all('a', text: 'Entire Team').last.click
    end
    within('#mainContent') do
      expect(page).to have_content('User2 ON')
      expect(page).to have_no_content('Item2 ON')
    end

    within('#sidenav') do
      click_link 'User2 ON'
    end
    within('#mainContent') do
      expect(page).to have_content('Item2 ON')
    end
  end
end
