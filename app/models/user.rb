# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  encrypted_password :string(128)
#  salt               :string(128)
#  confirmation_token :string(128)
#  remember_token     :string(128)
#  email_confirmed    :boolean         not null
#  created_at         :datetime
#  updated_at         :datetime
#

class User < ActiveRecord::Base
  include Clearance::User
    
  has_many :users_packages
  has_many :packages, :through => :users_packages
  
  def variants_for_approve
    Variant.suggested_by_user(self)
  end
  
end
