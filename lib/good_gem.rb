module GoodGem
  
  class << self
    def config
      @@config ||= {}
    end
    
    require 'config/system'
    
    def update_specs
      gz_path = File.join(RAILS_ROOT, 'specs.4.8.gz')
      plain_path = File.join(RAILS_ROOT, 'specs.4.8')
      # `wget #{GoodGem.config[:specs_url]} -O #{gz_path}`
      
      # `gzip -dfv -c #{gz_path} > #{plain_path}`

      data = Marshal.load(File.open(plain_path, 'r') { |f| f.read })[0..100]

      packages = []
      last_versions = {}
      data.each do |name, version, lang|
        if ((exists = last_versions[name]) && exists[1] < version) || exists.nil?    
          last_versions[name] = [name, version, lang]
        end
      end

      last_versions.each do |k, (name, version, lang)|
        unless (package = Package.find(:first, :conditions => {:original_name => name, :version => version}))
          package = Package.create :original_name => name, :version => version

          puts "Receive specs for #{package.name}"
          package.receive_spec
        end

        package.variants.select { |v| v.is_generated == false }.each do |variant|
          puts "Generating #{variant.deb_name}"
          variant.generate
        end
      end
      
      all_variants.each do |platform, arch|
        puts "Generating packages for platform #{platform} and arch #{arch}"
        dist_path = Variant.dist_path(platform, arch)
        dist_path.mkpath
        (dist_path + 'Packages_new').open('w') do |f|     
          Package.all.each do |package|
            variant = package.variant_for(platform, arch)
            unless variant.is_generated?
              variant.generate
            end                      
            f.puts "#{variant.control_file(true)}\n\n"
          end
        end
        FileUtils.mv((dist_path + 'Packages_new').to_s, (dist_path + 'Packages').to_s, :force => true)
      end
      
      # File.open(File.join(RAILS_ROOT, specs.4.8), 'w') do |packages|
      #   last_versions.each do |k, (orig_name, version, lang)|
      #     name = orig_name.downcase.gsub(/[^\w\d-]/, '')
      #     name = name.gsub('_', '-')
      #     if name.present? && name =~ /^\w/ && name.size > 1
      #       package_name = "#{name}-#{version}"
      #       if (gem_spec = DB[package_name])
      #         gem_spec = Marshal.load(gem_spec)
      #       else        
      #         puts "Generating gem #{package_name}"
      #         control, md5, sha1, sha256, size = make_deb(orig_name, name, version)
      #         gem_spec = { :name => name, :version => version, :lang => lang, :control => control, :md5 => md5, :sha1 => sha1, :sha256 => sha256, :size => size}
      #         DB[package_name] = Marshal.dump(gem_spec)
      #       end
      #       res = "#{gem_spec[:control]}SHA256: #{gem_spec[:sha256]}\nSHA1: #{gem_spec[:sha1]}\nMD5sum: #{gem_spec[:md5]}\nSize: #{gem_spec[:size]}\n\n"
      #       puts "Adding gem #{package_name} to packages"
      #       packages.puts res
      #     end
      #   end  
      # end
    end
    
    def update_package_files
      
    end
    
    # def time_for_specs?
    #   val = Misc.find_by_key('last_spec_update')
    #   !val && val[:time] < 1.hour.ago
    # end
    
    def all_variants
      variants = [['all', 'all']]
      config[:platforms].each do |platform|
        (['all'] + config[:archs]).each do |arch|
          variants << [platform, arch]
        end
      end
      variants
    end
    
  end
  
end