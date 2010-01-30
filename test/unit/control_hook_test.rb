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

require 'test_helper'

class ControlHookTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
