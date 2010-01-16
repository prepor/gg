require 'open-uri'

class Package
  include MongoMapper::Document
  after_create :add_main_maintainer, :add_first_variant, :set_created_at
  
  key :name, String
  key :original_name, String
  key :created_at, Time
  
  key :version, Gem::Version  
  key :is_generated, Boolean
  
  key :description, String
  key :authors, String
  
  key :project_uri, String
  key :gem_uri, String
  
  many :variants
  
  many :maintainers, :class => User
    
  def maintainers_list
    mainteiners.map { |v| "#{v.name} <#{v.email}>"} * ', '
  end
  
  def add_main_maintainer
    maintainers << User.find_by_email(GoodGem.config[:main_maintainer][:email])
  end
  
  def add_first_variant
    variant = Variant.new( :platform => 'all',
                            :arch => 'all')

    variants << variant
    variant.postinst = ["#!/bin/sh",
                        "echo \"Gem installing\"",
                        "gem install #{original_name} -v #{version.to_s}}"
                        ] * "\n"
    variant.postrm = ["#!/bin/sh",
                      "echo \"Gem uninstalling\"",
                      "gem uninstall #{original_name} -v #{version.to_s}}"
                      ] * "\n"
  end
  
  def receive_spec
    desc = ActiveSupport::JSON.decode(open(GoodGem.config[:gems_api_url] + "#{original_name}.json"))
    last_version = Gem::Version.new(desc['version'])
    if version != last_version
      version = last_version
      variants.each do |variant|
        variant.is_generated = false
      end
    end
    description = desc['info']
    authors = desc['info']
    project_uri = desc['project_uri']
    gem_uri = desc['gem_uri']
    save
  end  
end