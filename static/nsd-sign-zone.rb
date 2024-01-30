# frozen_string_literal: true

require 'open3'
require 'optparse'
require 'date'

require 'nsd_key'

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

  opts.on('-k', '--ksk-file=KSK', 'Location of key-signing key (KSK) file.') do |ksk|
    options[:ksk] = File::expand_path ksk
  end

  opts.on('-z', '--zsk-metadata=ZSK_METADATA',
          'Location of path containing zone-signing key (ZSK) metadata file.') do |zsk_metadata|
    options[:zsk_metadata] = zsk_metadata
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

zonefile = File::expand_path(ARGV[0])

def ensure_file(name, file)
  raise "missing #{name} file: #{file}" unless File::exist?(file)
  raise "#{name} file not readable: #{file}" unless File::readable?(file)
end

raise 'missing required parameter: KSK' unless options[:ksk]

raise 'missing required parameter: ZSK_METADATA' unless options[:zsk_metadata]

raise 'missing required parameter: DOMAIN' unless options[:domain]

ensure_file('ksk private key', options[:ksk])
ensure_file('zsk metadata file', options[:zsk_metadata])
ensure_file('zonefile', zonefile)

verbose = options[:verbose]

all_zsks = NsdKey::read_metadata(options[:zsk_metadata], verbose)

valid_zsks = all_zsks.select(&:valid?)

raise 'no valid zone-signing keys found!' if valid_zsks.empty?

valid_zsks.each do |k|
  ensure_file('zsk public key', k.public_key)
  ensure_file('zsk private key', k.private_key)
end

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

signing_keys = (valid_zsks.map(&:private_key) + [options[:ksk]]).map { |kf| kf.gsub(/\.private$/, '') }

puts "signing #{options[:domain]} zonefile #{zonefile} with keys: #{signing_keys.join(', ')}" if verbose

exec!(verbose, "signing zonefile #{zonefile} ...",
      [
        'ldns-signzone',
        opt_str(options.key?(:output_file), "-f #{options[:output_file]}"),
        "-o #{options[:domain]}",
        "-i #{options[:inception]}",
        "-e #{options[:expiry]}",
        '-u',
        '-n',
        '-p',
        '-s $(head -n 1000 /dev/random | sha1sum | cut -b 1-16)',
        zonefile,
        signing_keys.join(' ')
      ].join(' '))

puts "zone #{options[:domain]} zonefile #{zonefile} signed!" if verbose
