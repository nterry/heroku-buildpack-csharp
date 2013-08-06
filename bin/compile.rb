#!/usr/bin/env ruby

# sync output
$stdout.sync = true

require_relative '../lib/language_pack'

Instrument.trace 'compile', 'app.compile' do
  if pack = LanguagePack.detect(ARGV[0], ARGV[1])
    pack.log('compile') do
      pack.compile
    end
  end
end
