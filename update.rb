require 'vendor/gems/environment.rb'
require "rufus-tokyo"
require 'pathname'
require 'active_support'

PUBLIC_PATH = Pathname.new('/home/gg/shared/public')

ROOT_PATH = Pathname.new(File.dirname(__FILE__))
DB = Rufus::Tokyo::Cabinet.new('data/db.tch')

def make_deb(orig_name, name, version)
  package_name = "#{name}-#{version}"
  path = PUBLIC_PATH + 'public/pool' + (package_name)
  deb_path = path + 'DEBIAN'
  deb_path.mkpath unless deb_path.exist?
  control = <<EOF
Package: gem-#{name}
Version: #{version}
Architecture: all
Depends: rubygems
Maintainer: GoodGem
Installed-Size: 5776
Priority: extra
Section: net
Filename: pool/#{package_name}.deb
Description: Gem package by GoodGem
EOF
  (deb_path + 'control').open('w') do |f|
    f.puts control
  end
  (deb_path + 'postinst').open('w') do |f|
    str = <<EOF
#!/bin/sh

echo "Gem installing"
gem install #{orig_name} -v #{version}

EOF
    f.puts str
  end
  
  (deb_path + 'postrm').open('w') do |f|
    str = <<EOF
#!/bin/sh

echo "Gem uninstalling"
gem uninstall #{orig_name} -v #{version}

EOF
    f.puts str
  end
  
  
  files = [(deb_path + 'control'), (deb_path + 'postinst'), (deb_path + 'postrm')]
  files.each do |file|
    file.chmod(0755)
  end
  `dpkg-deb -z0 -b #{path.to_s}`
  FileUtils.rm_r(path.to_s)
  md5 = `openssl dgst -md5 #{path.to_s}.deb`.match(/= (.+)/)[1]
  sha1 = `openssl dgst -sha #{path.to_s}.deb`.match(/= (.+)/)[1]
  sha256 = `openssl dgst -sha256 #{path.to_s}.deb`.match(/= (.+)/)[1]
  [control, md5, sha1, sha256, File.size("#{path.to_s}.deb")]
end

`wget http://gemcutter.org/specs.4.8.gz`
`gzip -dfv specs.4.8.gz`

data = Marshal.load(File.open('specs.4.8', 'r') { |f| f.read })

last_versions = {}
data.each do |name, version, lang|
  if ((exists = last_versions[name]) && exists[1] < version) || exists.nil?    
    last_versions[name] = [name, version, lang]
  end
end
File.open('Packages_new', 'w') do |packages|
  last_versions.each do |k, (orig_name, version, lang)|
    name = orig_name.downcase.gsub(/[^\w\d-]/, '')
    name = name.gsub('_', '-')
    if name.present? && name =~ /^\w/ && name.size > 1
      package_name = "#{name}-#{version}"
      if (gem_spec = DB[package_name])
        gem_spec = Marshal.load(gem_spec)
      else        
        puts "Generating gem #{package_name}"
        control, md5, sha1, sha256, size = make_deb(orig_name, name, version)
        gem_spec = { :name => name, :version => version, :lang => lang, :control => control, :md5 => md5, :sha1 => sha1, :sha256 => sha256, :size => size}
        DB[package_name] = Marshal.dump(gem_spec)
      end
      res = "#{gem_spec[:control]}SHA256: #{gem_spec[:sha256]}\nSHA1: #{gem_spec[:sha1]}\nMD5sum: #{gem_spec[:md5]}\nSize: #{gem_spec[:size]}\n\n"
      puts "Adding gem #{package_name} to packages"
      packages.puts res
    end
  end  
end

FileUtils.mv 'Packages_new', (PUBLIC_PATH + 'Packages').to_s, :force => true