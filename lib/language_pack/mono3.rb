require_relative '../language_pack'
require_relative 'mono2'

class LanguagePack::Mono3 < LanguagePack::Mono2
  MONO_BASE_URL        = 'https://s3.amazonaws.com/mono-bin'
  MONO_VERSION         = 'mono3/mono-3.2.1'

  def self.use?
    false if Dir.glob('*.sln').empty?
    if File.exist? '.monoproperties'
      file = YAML.load_file('.monoproperties').to_sym
      file[:runtime][:version].scan(/(\d+)\.?/)[0][0] == '3' if file[:runtime][:version]
    end
  end

  # list of default addons to install
  def default_addons
    {}
  end


  def default_config_vars
    {}
  end


  def default_process_types
    { 'web' => 'mono-sgen CROWBAR.exe $PORT' }
  end

end