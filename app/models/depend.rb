# == Schema Information
#
# Table name: depends
#
#  id           :integer         not null, primary key
#  name         :string(255)
#  compare_type :string(255)
#  version      :string(255)
#  variant_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Depend < ActiveRecord::Base
  CompareTypes = ['<<', '<=', '=', '>=', '>>']
  
  validates_presence_of :name
  
  validates_inclusion_of :compare_type, :in => CompareTypes, :allow_blank => true
  
  def for_list
    name + (version.present? ? " (#{compare_type} #{version})" : '')
  end
  
end
