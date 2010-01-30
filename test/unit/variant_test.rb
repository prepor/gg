# == Schema Information
#
# Table name: variants
#
#  id           :integer         not null, primary key
#  platform     :string(255)
#  arch         :string(255)
#  lang         :string(255)
#  sha256       :string(255)
#  sha1         :string(255)
#  md5          :string(255)
#  size         :string(255)
#  is_generated :boolean
#  package_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#

require 'test_helper'

class VariantTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
