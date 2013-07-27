require_relative '../language_pack'
require_relative 'mono2'

require 'yaml'

class LanguagePack::Mono3 < LanguagePack::Mono2

  def use?
    #(super.use? && file.exist?('.monoproperties') && YAML::parse('.monoproperties').keys)
  end

  # name of the Language Pack
  # @return [String] the result
  def name
    'C#'
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

end