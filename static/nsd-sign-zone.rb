# frozen_string_literal: true

require 'open3'
require 'optparse'
require 'date'

require_relative 'nsd_key'

options = {
  inception: Date::today.strftime('%Y%m%d'),
  expiry: (Date::today + 30).strftime('%Y%m%d'),
  verbose: false
}

# rubocop:disable Metrics/BlockLength
OptionParser.new do |opts|
  opts.banner = "usage: #{File::basename $PROGRAM_NAME} [opts] <ZONE_FILE>"

  opts.on('-d', '--domain=DOMAIN', 'Domain name of zone.') do |domain|
    options[:domain] = domain
  end

  opts.on('-k', '--key-signing-key=KSK', 'Location of key-signing key (KSK) file.') do |ksk|
    options[:ksk] = ksk
  end

  opts.on('-z', '--zone-signing-key-dir=ZSK_DIR',
          'Location of path containing zone-signing key (ZSK) files and metadata.') do |zsk_dir|
    options[:zsk_dir] = zsk_dir
  end

  opts.on('-o', '--output=OUTPUT_FILE', 'File in which to output zigned zone.') do |output_file|
    options[:output_file] = output_file
  end

  opts.on('-i', '--inception=DATE',
          'Date at which the signed zone is valid (YYYYMMdd). Default to today.') do |inception|
    options[:inception] = inception
  end

  opts.on('-x', '--expiry=DATE',
          'Date at which the signed zone expires (YYYYMMdd). Defaults to 30 days from now.') do |expiry|
    options[:expiry] = expiry
  end

  opts.on('-h', '--help', 'Print this message.') do
    puts opts
    exit(0)
  end

  opts.on('-v', '--verbose', 'Provide verbose output.') { options[:verbose] = true }
end.parse!
# rubocop:enable Metrics/BlockLength

raise 'missing required parameter: ZONE_FILE' unless ARGV.length == 1

zonefile = ARGV[0]

raise 'missing required parameter: KSK' unless options[:ksk]

raise 'missing required parameter: ZSK_DIR' unless options[:zsk_dir]

raise 'missing required parameter: DOMAIN' unless options[:domain]

raise "KSK file does not exist: #{options[:ksk]}" unless File::exist?(options[:ksk])

raise "ZSK directory does not exist: #{options[:zsk_dir]}" unless File::directory?(options[:zsk_dir])

verbose = options[:verbose]

all_zsks = NsdKey::read_keys(options[:zsk_dir], verbose)

valid_zsks = all_zsks.select(&:valid?)

raise 'no valid zone-signing keys found!' if valid_zsks.empty?

def ensure_file(name, file)
  raise "missing #{name} file: #{file}" unless File::exist?(file)
  raise "#{name} file not readable: #{file}" unless File::readable?(file)
end

valid_zsks.each do |k|
  ensure_file('zsk public key', k.public_key)
  ensure_file('zsk private key', k.private_key)
end

ensure_file('ksk', options[:ksk])

def exec!(verbose, msg, cmd)
  puts msg if verbose
  print "  $ #{cmd} ... " if verbose
  out, status = Open3::capture2e(cmd)
  puts((status.success? ? 'success.' : 'failed!')) if verbose

  raise "failed execution of '#{cmd}': #{out}'" unless status.success?

  status.success?
end

def opt_str(cond, str)
  cond ? str : ''
end

signing_keys = ([ksk] + valid_zsks.map(&:private_key)).map { |kf| kf.gsub(/\.private$/, '') }

puts "signing keys: #{signing.keys.join(', ')}" if verbose

exec!(verbose, "signing zonefile #{zonefile} ...",
      [
        'ldns-signzone',
        opt_str(options.key?(:output_file), "-f #{options[:output_file]}"),
        "-o #{options[:domain]}",
        "-i #{options[:inception]}",
        "-e #{options[:expiry]}",
        '-u',
        '-A',
        signing_keys.join(' ')
      ].join(' '))

puts "zone #{domain} signed!" if verbose
