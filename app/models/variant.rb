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


class Variant < ActiveRecord::Base
  ControlHooks = ['postinst', 'postrm', 'preinst', 'prerm']
  
  # before_create :add_default_depends
  
  named_scope :approved, :conditions => { :state => 'approved' }
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :package
  
  has_many :depends
  
  has_many :control_hooks
  
  has_many :users_packages, :foreign_key => :package_id, :primary_key => :package_id
  has_many :maintainers, :class_name => 'User', :through => :users_packages, :source => :user
  
  accepts_nested_attributes_for :depends
  accepts_nested_attributes_for :control_hooks
  
  def self.suggested_by_user(user)
    self.with_exclusive_scope do
      all :conditions => { :state => 'suggested', :'users_packages.user_id' => user.id }, :joins => :users_packages
    end
  end
  
  def control_file(for_index = false)
    file = ["Package: gem-#{package.name}",
    "Version: #{package.version.to_s}",
    "Architecture: #{arch}",
    "Depends: #{depends_list}",
    "Maintainer: #{package.maintainers_list}",
    "Priority: extra",
    "Section: gems",
    "Filename: #{pool_deb_path}"]
    if for_index
      file << "Size: #{size}"
      file << "SHA1: #{sha1}"
      file << "SHA256: #{sha256}"
      file << "MD5sum: #{md5}"
    end
    file << "Description: #{package.description.gsub("\n", ' ')}"
    file * "\n"
  end
  
  ControlHooks.each do |hook|
    define_method hook do
      control_hooks.find_by_name(hook)
    end
    define_method "#{hook}=" do |val|
      control_hooks << ControlHook.new(:name => hook, :content => val)
    end
  end
  
  def make_deb
    deb_path.mkpath unless deb_path.exist?
    ([['control', control_file]] + control_hooks.map { |v| [v.name, v.content] }).each do |file_name, content|
      file_path = deb_path + file_name
      file_path.open('w') do |f|
        f.puts content
      end
      file_path.chmod(0755)
    end
    `dpkg-deb -z0 -b #{path.to_s}`
    FileUtils.rm_r(path.to_s)
    self.md5 = `openssl dgst -md5 #{path.to_s}.deb`.match(/= (.+)/)[1]
    self.sha1 = `openssl dgst -sha #{path.to_s}.deb`.match(/= (.+)/)[1]
    self.sha256 = `openssl dgst -sha256 #{path.to_s}.deb`.match(/= (.+)/)[1]
    self.size = File.size("#{path.to_s}.deb")
  end
  
  def self.dist_path(platform, arch)
    path = GoodGem.config[:dists_path]
    path += platform unless platform == 'all'
    path += arch unless arch == 'all'
    path
  end
  
  def pool_path(platform, arch)
    path = GoodGem.config[:pool_path]
    path += platform unless platform == 'all'
    path += arch unless arch == 'all'
    path
  end
  
  def path(for_deb = false)
    @path ||= self.pool_path(platform, arch) + (package.name + '-' + package.version.to_s + (for_deb ? '.deb' : ''))
  end
  
  def pool_deb_path
    path(true).relative_path_from(GoodGem.config[:pool_path] + '..')
  end
  
  def deb_path
    @deb_path ||= path + 'DEBIAN'
  end
  
  def depends_list
    depends.map { |v| v.for_list } * ','
  end
  
  def deb_name
    "#{package.name}-#{package.version.to_s}"
  end
  
  def generate    
    make_deb
    self.is_generated = true
    save
  end  
  
  def after_create
    # GoodGem.update_index(self)
  end
  
  def add_default_depends
    depends << Depend.new(:name => 'rubygems')
  end
  
  def add_default_hooks
    self.preinst = ["#!/bin/sh",
                        "echo \"Gem installing\"",
                        "gem install #{package.original_name} -v #{package.version.to_s}"
                        ] * "\n"
    self.prerm = ["#!/bin/sh",
                      "echo \"Gem uninstalling\"",
                      "gem uninstall #{package.original_name} -v #{package.version.to_s}"
                      ] * "\n"
  end
  
  def set_hooks_for_new
    add_default_hooks
    (ControlHooks - ['preinst', 'prerm']).each do |hook|
      control_hooks.build :name => hook, :content => ''
    end
  end
  
  def move_old_variant_to_archive
    package.variants.approved.all(:conditions => { :platform => platform, :arch => arch }).each do |variant|
      variant.update_attributes :state => 'archived'
    end
  end
  
  def send_notifications_about_suggest
    
  end
  
  def send_notification_about_approve
    
  end
  
  def send_notification_about_decline
    
  end
  
  def approve!
    self.state = 'approved'
    send_notification_about_approve
    save
  end
  
  def decline!
    self.state = 'declined'
    send_notification_about_decline
    save
  end
  
  def before_create
    if package.maintainers.include?(created_by)
      self.state = 'approved'
      move_old_variant_to_archive
    else
      self.state = 'suggested'
      send_notifications_about_suggest
    end
  end
  
  
end
