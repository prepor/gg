# == Schema Information
#
# Table name: control_hooks
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  content         :string(255)
#  last_edit_at    :datetime
#  is_default      :boolean         default(TRUE)
#  last_edit_by_id :integer
#  variant_id      :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class ControlHook < ActiveRecord::Base
  validates_presence_of :name
  
  belongs_to :last_edit_by, :class_name => User
end
