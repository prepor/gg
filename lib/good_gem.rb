module GoodGem
  
  class << self
    def config
      @@config ||= {}
    end
    
    require 'config/system'
    
    def update_specs
      data = receive_specs
      update_variants last_versions(data)
      update_package_files
    end
    
    def update_variants(versions)
      versions.each do |k, (name, version, lang)|
        package = Package.find_or_initialize_by_original_name(name)
        if package.version != version
          package.version = version
          if !package.new_record? || package.save
            puts "Receive specs for #{package.name}"
            package.receive_spec
          end
        end
      end
    end
    
    def update_package_files
      all_variants.each do |platform, arch|
        puts "Generating packages for platform #{platform} and arch #{arch}"
        dist_path = Variant.dist_path(platform, arch)
        dist_path.mkpath
        (dist_path + 'Packages_new').open('w') do |f|     
          Package.find(:all, :conditions => { :is_spec_received => true }).each do |package|
            variant = package.variant_for(platform, arch)
            unless variant.is_generated?
              puts "Generating #{variant.deb_name}"
              variant.generate
            end                      
            f.puts "#{variant.control_file(true)}\n\n"
          end
        end
        FileUtils.mv((dist_path + 'Packages_new').to_s, (dist_path + 'Packages').to_s, :force => true)
      end
    end
    
    def all_variants
      variants = [['all', 'all']]
      config[:platforms].each do |platform|
        (['all'] + config[:archs]).each do |arch|
          variants << [platform, arch]
        end
      end
      variants
    end
    
    def receive_specs
      gz_path = File.join(RAILS_ROOT, 'specs.4.8.gz')
      plain_path = File.join(RAILS_ROOT, 'specs.4.8')
      `wget #{GoodGem.config[:specs_url]} -O #{gz_path}`
      
      `gzip -dfv -c #{gz_path} > #{plain_path}`

      Marshal.load(File.open(plain_path, 'r') { |f| f.read })
    end
    
    def last_versions(data)
      last_versions = {}
      data.each do |name, version, lang|
        if ((exists = last_versions[name]) && exists[1] < version) || exists.nil?    
          last_versions[name] = [name, version, lang]
        end
      end
      last_versions
    end
    
  end
  
end