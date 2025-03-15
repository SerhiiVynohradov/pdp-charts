require 'rails_helper'

RSpec.feature 'User - Sidenav' do
  context 'company present' do
    context 'company charts on' do
      context 'team present' do
        context 'team charts on' do
          let!(:company) { create(:company, name: 'My Company', charts_visible: true) }
          let!(:team1) { create(:team, name: 'My Team 1', charts_visible: true, company: company) }
          let!(:team2) { create(:team, name: 'My Team 2', charts_visible: true, company: company) }
          let!(:user1) { create(:user, :user, name: 'John Smith', team: team1) }
          let!(:user2) { create(:user, :user, name: 'Jane Doe', team: team1) }
          let!(:user3) { create(:user, :user, name: 'John Doe', team: team2) }
          let!(:user4) { create(:user, :user, name: 'Jane Smith', team: team2) }

          let!(:item1) { create(:item, user: user1, name: 'User 1 Item') }
          let!(:item2) { create(:item, user: user2, name: 'User 2 Item') }
          let!(:item3) { create(:item, user: user3, name: 'User 3 Item') }
          let!(:item4) { create(:item, user: user4, name: 'User 4 Item') }

          before do
            login_as(user1, scope: :user)
            visit my_items_path(locale: :en)
          end

          it 'should have the company in side menu' do

          end
        end

        context 'other team charts off' do

        end

        context 'team charts off' do

        end
      end

      context 'team absent' do
        # impossible?

      end
    end

    context 'company charts off' do
      context 'team present' do
        context 'team charts on' do

        end

        context 'team charts off' do

        end
      end

      context 'team absent' do
        # impossible?

      end
    end
  end

  context 'company absent' do
    context 'team present' do
      context 'team charts on' do
        let(:team) { create(:team, charts_visible: true) }
        let!(:user1) { create(:user, :user, name: 'John Smith', team: team) }
        let!(:user2) { create(:user, :user, name: 'Jane Doe', team: team) }
        let!(:item1) { create(:item, user: user1, name: 'User 1 Item') }
        let!(:item2) { create(:item, user: user2, name: 'User 2 Item') }

        before do
          login_as(user1, scope: :user)
          visit my_items_path(locale: :en)
        end

        it 'should have the team in side menu' do
          within('#sidenav') do
            expect(page).to have_content('Team')
            expect(page).to have_content('John Smith')
            expect(page).to have_content('Jane Doe')
            expect(page).to have_content('Entire Team')
          end

          within('#sidenav') do
            click_link('Jane Doe')
          end

          expect(page).to have_content('User 2 Item')
          expect(page).to have_no_content('User 1 Item')

          within('#sidenav') do
            click_link('John Smith')
          end

          expect(page).to have_content('User 1 Item')
          expect(page).to have_no_content('User 2 Item')
        end
      end

      context 'team charts off' do
        let(:team) { create(:team, charts_visible: false) }
        let!(:user1) { create(:user, :user, name: 'John Smith', team: team) }
        let!(:user2) { create(:user, :user, name: 'Jane Doe', team: team) }
        let!(:item1) { create(:item, user: user1, name: 'User 1 Item') }
        let!(:item2) { create(:item, user: user2, name: 'User 2 Item') }

        before do
          login_as(user1, scope: :user)
          visit my_items_path(locale: :en)
        end

        it 'should have the team in side menu' do
          within('#sidenav') do
            expect(page).to have_content('Team')
            expect(page).to have_content('John Smith')
            expect(page).to have_no_content('Jane Doe')
            expect(page).to have_no_content('Entire Team')
          end

          within('#sidenav') do
            click_link('John Smith')
          end

          expect(page).to have_content('User 1 Item')
          expect(page).to have_no_content('User 2 Item')
        end
      end
    end

    context 'team absent' do
      let!(:user) { create(:user, :user, name: 'John Smith') }
      let!(:item) { create(:item, user: user, name: 'Some Cool Item') }

      before do
        login_as(user, scope: :user)
        visit my_items_path(locale: :en)
      end

      it 'should not have the user in side menu' do
        within('#sidenav') do
          expect(page).to have_no_content('John Smith')
        end

        expect(page).to have_content('Some Cool Item')
      end
    end
  end
end
