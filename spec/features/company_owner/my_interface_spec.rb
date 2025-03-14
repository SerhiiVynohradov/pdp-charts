require 'rails_helper'

RSpec.feature 'Owner - My Interface' do
  context 'owner without compnay' do
    let!(:user) { create(:user, :company_owner) }
    let!(:item) { create(:item, user: user, name: 'Some Cool Item') }

    before do
      login_as(user, scope: :user)
    end

    context 'my items' do
      scenario 'should visit my interface' do
        visit my_items_path(locale: :en)
        expect(page).to have_content('PDP Charts')
        expect(page).to have_content('Create Company')
      end

      scenario 'should visit my interface' do
        visit my_root_path(locale: :en)
        expect(page).to have_content('PDP Charts')
        expect(page).to have_content('Create Company')
      end
    end

    context 'my item' do
      scenario 'should visit my interface' do
        visit my_item_path(item, locale: :en)
        expect(page).to have_content('PDP Charts')
        expect(page).to have_content('Create Company')
      end
    end
  end

  context 'owner with compnay' do
    let!(:company) { create(:company) }
    let!(:user) { create(:user, :company_owner, company: company) }
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
