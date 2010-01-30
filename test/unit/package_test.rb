# == Schema Information
#
# Table name: packages
#
#  id            :integer         not null, primary key
#  name          :string(255)
#  original_name :string(255)
#  version       :string(255)
#  description   :text
#  authors       :string(255)
#  project_uri   :string(255)
#  gem_uri       :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'test_helper'

class PackageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
