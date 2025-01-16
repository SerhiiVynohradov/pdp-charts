# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

regular_user = User.create email: 'user@gmail.com', password: 'password', password_confirmation: 'password', role: :user, company_id: nil, team_id: nil, name: 'User User'

company = Company.create name: 'Company'

team_without_company = Team.create name: 'Team without company', company_id: nil
team_with_company = Team.create name: 'Team with company', company_id: company.id

manager_of_team_without_company = User.create email: 'manager_of_team_without_company@gmail.com', password: 'password', password_confirmation: 'password', role: :manager, company_id: nil, team_id: team_without_company.id, name: 'Manager Manager'
user_of_team_without_company = User.create email: 'user_of_team_without_company@gmail.com', password: 'password', password_confirmation: 'password', role: :user, company_id: nil, team_id: team_without_company.id, name: 'User User'

manager_of_team_with_company = User.create email: 'manager_of_team_with_company@gmail.com', password: 'password', password_confirmation: 'password', role: :manager, company_id: company.id, team_id: team_with_company.id, name: 'Manager Manager'
user_of_team_with_company = User.create email: 'user_of_team_with_company@gmail.com', password: 'password', password_confirmation: 'password', role: :user, company_id: company.id, team_id: team_with_company.id, name: 'User User'
owner_of_team_with_company = User.create email: 'owner_of_team_with_company@gmail.com', password: 'password', password_confirmation: 'password', role: :company_owner, company_id: company.id, team_id: team_with_company.id, name: 'Owner Owner'

superadmin = User.create email: 'superadmin@gmail.com', password: 'password', password_confirmation: 'password', role: :superadmin, company_id: nil, team_id: nil, name: 'Superadmin Superadmin'

category1 = Category.create name: 'Work', description: "Прямі обов'язки (хард скіли) які мені потрібні для роботи в цій фірмі."
category2 = Category.create name: 'Life', description: "Все що мені потрібно робити щоб не здохнути на цій роботі."
Category.create name: 'Spiritual', description: "Духовний розвиток. Без якого все матеріальне не має змісту."
Category.create name: 'Material', description: "Матеріальні зацікавленості. Як заробляти, як мати більше фінансів, як мати більше речей і т.п."
Category.create name: 'Human', description: "Людські речі які мені важливо розвивати. Щось вижче ніж матеріальне і ніж духовне. Наприклад виконати мрію дитинства і піти в школу малювання і т.п."

Item.create user_id: regular_user.id, name: 'Item', description: 'Description', link: 'Link', reason: 'Reason', category: 'Category', status: 'Status', expected_results: 'Expected results', progress: 0, effort: 1, result: 'Result', certificate_link: 'Certificate link', position: 1
Item.create user_id: manager_of_team_without_company.id, name: 'Item', description: 'Description', link: 'Link', reason: 'Reason', category: 'Category', status: 'Status', expected_results: 'Expected results', progress: 0, effort: 1, result: 'Result', certificate_link: 'Certificate link', position: 1
Item.create user_id: user_of_team_without_company.id, name: 'Item', description: 'Description', link: 'Link', reason: 'Reason', category: 'Category', status: 'Status', expected_results: 'Expected results', progress: 0, effort: 1, result: 'Result', certificate_link: 'Certificate link', position: 1
Item.create user_id: manager_of_team_with_company.id, name: 'Item', description: 'Description', link: 'Link', reason: 'Reason', category: 'Category', status: 'Status', expected_results: 'Expected results', progress: 0, effort: 1, result: 'Result', certificate_link: 'Certificate link', position: 1
Item.create user_id: user_of_team_with_company.id, name: 'Item', description: 'Description', link: 'Link', reason: 'Reason', category: 'Category', status: 'Status', expected_results: 'Expected results', progress: 0, effort: 1, result: 'Result', certificate_link: 'Certificate link', position: 1
Item.create user_id: owner_of_team_with_company.id, name: 'Item', description: 'Description', link: 'Link', reason: 'Reason', category: 'Category', status: 'Status', expected_results: 'Expected results', progress: 0, effort: 1, result: 'Result', certificate_link: 'Certificate link', position: 1
