require_relative '../language_pack'
require_relative 'mono'

class LanguagePack::Mono2 < LanguagePack::Mono
  MONO_BASE_URL        = 'https://s3.amazonaws.com/mono-bin'
  MONO_VERSION         = 'mono2/mono-2.10.8.1'

  def self.use?
    false if Dir.glob('*.sln').empty?
    if File.exist? '.monoproperties'
      file = YAML.load_file('.monoproperties').to_sym
      file[:runtime][:version].scan(/(\d+)\.?/)[0][0] == '2' if file[:runtime][:version]
    end
  end

  # list of default addons to install
  def default_addons

  end

  # config vars to be set on first push.
  # @return [Hash] the result
  # @not: this is only set the first time an app is pushed to.
  def default_config_vars

  end

  # process types to provide for the app
  # Ex. for rails we provide a web process
  # @return [Hash] the result
  def default_process_types

  end

  # this is called to build the slug
  def compile

  end
end