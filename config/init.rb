Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")
$LOAD_PATH.unshift(Merb.root / "lib")

require 'yaml'
dependencies 'haml', 'merb_helpers', 'merb_has_flash', 'merb-mailer'
require 'digest/sha1'
require 'sass'
require 'recaptcha'
require 'merb_exceptions'
require 'RMagick'
require 'memcache'
require 'memcache_util'
require 'gchart'

use_orm :activerecord
use_test :rspec
use_template_engine :haml
Merb::Config.use do |c|
  c[:session_secret_key]  = 'ccf75249b0efbdb3edff96d0a1b16b19cf91f31e'
  c[:session_store] = :activerecord
  c[:sass] ||= {}
  c[:sass][:style] = :compact
end

Merb::BootLoader.after_app_loads do
  config_path = File.join(Merb.root, 'config', 'memcache.yml')
  memcache_connection_str = YAML::load_file(config_path) rescue 'localhost:11211'
  CACHE = MemCache.new memcache_connection_str
  
  Merb::Mailer.config = { :sendmail_path => '/usr/sbin/sendmail' }
  Merb::Mailer.delivery_method = :sendmail
  
  recaptcha_path = File.join(Merb.root, 'config', 'recaptcha.yml')
  if File.file?(recaptcha_path) and File.readable?(recaptcha_path)
    rc = YAML::load_file(recaptcha_path)
    ENV['RECAPTCHA_PUBLIC_KEY'] = rc[:public]
    ENV['RECAPTCHA_PRIVATE_KEY'] = rc[:private]
  else
    raise "ReCaptcha configuration file not found!"
  end
end
