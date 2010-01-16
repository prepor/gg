GoodGem.config.merge!({
  :platforms => ['ubuntu', 'debian'],
  :archs => ['i386', 'amd64'],
  :main_maintainer => { :name => 'Andrew Rudenko', :email => 'ceo@prepor.ru'},
  :pool_path => Pathname.new(File.join(RAILS_ROOT, 'public/pool')),
  :dists_path => Pathname.new(File.join(RAILS_ROOT, 'public/dists')),
  :specs_url => 'http://gemcutter.org/specs.4.8.gz',
  :gems_api_url => 'http://gemcutter.org/api/v1/gems/'
})