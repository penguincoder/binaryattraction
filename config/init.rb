Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")
$LOAD_PATH.unshift(Merb.root / "lib")
# Merb.push_path(:lib, Merb.root / "lib") # uses **/*.rb as path glob

dependencies 'haml', 'sass', 'merb_helpers', 'merb_has_flash', 'digest/sha1', 'recaptcha'

Merb::BootLoader.after_app_loads do
  recaptcha_path = File.join(Merb.root, 'config', 'recaptcha.yml')
  if File.file?(recaptcha_path) and File.readable?(recaptcha_path)
    rc = YAML::load_file(recaptcha_path)
    ENV['RECAPTCHA_PUBLIC_KEY'] = rc[:public]
    ENV['RECAPTCHA_PRIVATE_KEY'] = rc[:private]
  else
    raise "ReCaptcha configuration file not found!"
  end
end

use_orm :activerecord
use_test :rspec
use_template_engine :haml
Merb::Config.use do |c|
  c[:session_secret_key]  = 'ccf75249b0efbdb3edff96d0a1b16b19cf91f31e'
  c[:session_store] = :activerecord
  c[:sass] ||= {}
  c[:sass][:style] = :compact
end

