class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :items

  enum role: { selfemployed: 0, employee: 1, manager: 2, companyowner: 3, superadmin: 4 }

end
