require 'rails_helper'

RSpec.feature 'Manager - My Interface' do
  context 'manager without team' do
    let!(:user) { create(:user, :manager) }
    let!(:item) { create(:item, user: user, name: 'Some Cool Item') }

    before do
      login_as(user, scope: :user)
    end

    context 'my items' do
      scenario 'should visit my interface' do
        visit my_items_path(locale: :en)
        expect(page).to have_content('PDP Charts')
        expect(page).to have_content('Create Team')
      end

      scenario 'should visit my interface' do
        visit my_root_path(locale: :en)
        expect(page).to have_content('PDP Charts')
        expect(page).to have_content('Create Team')
      end
    end

    context 'my item' do
      scenario 'should visit my interface' do
        visit my_item_path(item, locale: :en)
        expect(page).to have_content('PDP Charts')
        expect(page).to have_content('Create Team')
      end
    end
  end

  context 'manager with team' do
    let!(:team) { create(:team) }
    let!(:user) { create(:user, :manager, team: team) }
    let!(:item) { create(:item, user: user, name: 'Some Cool Item') }

    before do
      login_as(user, scope: :user)
    end

    context 'my items' do
      scenario 'should visit my interface' do
        visit my_items_path(locale: :en)
        expect(page).to have_content('PDP Charts')
        expect(page).to have_content('Some Cool Item')
      end

      scenario 'should visit my interface' do
        visit my_root_path(locale: :en)
        expect(page).to have_content('PDP Charts')
        expect(page).to have_content('Some Cool Item')
      end
    end

    context 'my item' do
      scenario 'should visit my interface' do
        visit my_item_path(item, locale: :en)
        expect(page).to have_content('PDP Charts')
        expect(page).to have_content('Some Cool Item')
      end
    end
  end
end
