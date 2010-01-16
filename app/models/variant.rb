class Variant
  ControlHooks = ['postinst', 'postrm', 'preinst', 'prerm']
  
  include MongoMapper::EmbeddedDocument
  
  before_create :add_default_depends
  
  key :platform, String
  key :arch, String
  
  key :lang, String
  key :sha256, String
  key :sha1, String
  key :md5, String
  key :size, Integer
  
  key :is_generated, Boolean, :default => false
  
  many :depends
  
  many :control_hooks
  
  one :package
  
  def control_file(for_index = false)
    file = ["Package: gem-#{package.name}",
    "Version: #{package.version.to_s}",
    "Architecture: #{arch}",
    "Depends: #{depends_list}",
    "Maintainer: #{package.maintainers_list}",
    "Priority: extra",
    "Section: gems",
    "Filename: #{deb_name}"]
    if for_index
      file << "SHA1: #{sha1}"
      file << "SHA256: #{sha256}"
      file << "MD5sum: #{md5}"
    end
    file << "Description: #{package.description}"
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
    (['control', control_file] + control_hooks.map { |v| [v.name, v.content] }).each do |file_name, content|
      file_path = deb_path + file_name
      file_path.open('w') do |f|
        f.puts content
      end
      file_path.chmod(0755)
    end
    `dpkg-deb -z0 -b #{path.to_s}`
    FileUtils.rm_r(path.to_s)
    md5 = `openssl dgst -md5 #{path.to_s}.deb`.match(/= (.+)/)[1]
    sha1 = `openssl dgst -sha #{path.to_s}.deb`.match(/= (.+)/)[1]
    sha256 = `openssl dgst -sha256 #{path.to_s}.deb`.match(/= (.+)/)[1]
    size = File.size("#{path.to_s}.deb")
  end
  
  def self.dist_path(platform, arch)
    path = GoodGem.config[:dists_path]
    path += platform unless platform == 'all'
    path += arch unless arch == 'all'
    path
  end
  
  def path
    @path ||= dist_path(platform, arch) + package_name
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
  end
  
  
  def after_create
    # GoodGem.update_index(self)
  end
  
  def add_default_depends
    depends << Depend.new(:name => 'rubygems')
  end
  
end