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

require 'test_helper'

class DependTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
