#!/usr/bin/env ruby

# sync output
$stdout.sync = true

require_relative '../lib/language_pack'

Instrument.trace 'detect', 'app.detect' do
  if pack = LanguagePack.detect(ARGV.first)
    puts pack.name
    exit 0
  else
    puts 'no'
    exit 1
  end
end