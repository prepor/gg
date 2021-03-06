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

require 'open-uri'

class Package < ActiveRecord::Base
  has_many :users_packages
  has_many :maintainers, :class_name => 'User', :through => :users_packages, :source => :user
  
  has_many :variants
  
  after_create :set_defaults
  
  validates_presence_of :original_name
  validates_presence_of :version
    
  def maintainers_list
    maintainers.map { |v| "#{v.name} <#{v.email}>"} * ', '
  end
  
  def add_main_maintainer
    self.maintainers << User.find_by_email(GoodGem.config[:main_maintainer][:email])
  end
  
  def add_first_variant
    variant = variants.create(  :platform => 'all',
                                :arch => 'all',
                                :created_by => maintainers.first)
                       

    variant.add_default_depends
    variant.add_default_hooks
  end
  
  def variants_for(platform)
    variants = self.variants.approved
    variants.select { |v| v.platform == platform || v.platform == 'all' }
  end
  
  def version
    Gem::Version.new(super)
  end
  
  def version=(val)
    super(val.to_s)
  end
  
  def receive_spec
    desc = nil
    begin
      desc = ActiveSupport::JSON.decode(open(GoodGem.config[:gems_api_url] + "#{original_name}.json").read)
    rescue StandardError => e
      puts "Error while receiving specs for #{name}"
    end
    if desc
      last_version = Gem::Version.new(desc['version'])
      if version != last_version
        self.version = last_version
        variants.each do |variant|
          variant.is_generated = false
        end
      end
      self.is_spec_received = true
      self.description = desc['info']
      self.authors = desc['info']
      self.project_uri = desc['project_uri']
      self.gem_uri = desc['gem_uri']
      save
    end
  end
  
  def set_created_at
    self.created_at = Time.zone.now    
  end
  
  def set_defaults
    set_name
    add_main_maintainer
    add_first_variant
    set_created_at    
    save
  end
  
  def set_name
    self.name = original_name.downcase.gsub(/[^\w\d-]/, '').gsub('_', '-')
  end
end
