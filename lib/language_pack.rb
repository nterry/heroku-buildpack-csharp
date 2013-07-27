require 'pathname'

# General Language Pack module
module LanguagePack

  # detects which language pack to use
  # @param [Array] first argument is a String of the build directory
  # @return [LanguagePack] the {LanguagePack} detected
  def self.detect(*args)
    Dir.chdir(args.first)

    pack = [ Mono2, Mono3 ].detect do |klass|
      klass.use?
    end

    pack ? pack.new(*args) : nil
  end

end

require_relative '../vendor/instrument'
require_relative 'language_pack/mono2'
require_relative 'language_pack/mono3'

