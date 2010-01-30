# == Schema Information
#
# Table name: users_packages
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  package_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class UsersPackage < ActiveRecord::Base
  belongs_to :user
  belongs_to :package
end
