# frozen_string_literal: true

require 'open3'
require 'optparse'

require_relative('nsd_key')

options = {
  algorithm: 'ECDSAP256SHA256',
  period: 90,
  overlap: 10,
  metadata: 'metadata.json',
  verbose: false
}

OptionParser.new do |opts|
  opts.banner = "usage: #{File::basename $PROGRAM_NAME} [opts] <DOMAIN>"

  opts.on('-a', '--algorithm=ALGORITHM', 'Algorithm used to generate keys.') do |algo|
    options[:algorithm] = algo
  end

  opts.on('-k', '--key-directory=KEY_DIRECTORY', 'Directory used for storing keys and metadata.') do |dir|
    options[:directory] = File::expand_path dir
  end

  opts.on('-p', '--validity-period=PERIOD', 'Period for which ZSK should be valid (in days).') do |period|
    options[:period] = period.to_i
  end

  opts.on('-o', '--period-overlap=OVERLAP', 'Period for which ZSK should overlap (in days).') do |overlap|
    options[:overlap] = overlap.to_i
  end

  opts.on('-m', '--metadata=METADATA_FILE', 'Location of key metadata JSON file.') do |metadata|
    options[:metadata] = metadata
  end

  opts.on('-h', '--help', 'Print this message.') do
    puts opts
    exit(0)
  end

  opts.on('-v', '--verbose', 'Provide verbose output.') { options[:verbose] = true }
end.parse!

raise 'missing required parameter: DOMAIN' unless ARGV.length == 1

domain = ARGV[0]

raise 'missing required parameter: KEY_DIRECTORY' unless options[:directory]

raise "key directory does not exist: #{options[:directory]}" unless File::directory?(options[:directory])

verbose = options[:verbose]

def exec!(verbose, msg, cmd)
  puts msg if verbose
  print "  $ #{cmd} ... " if verbose
  out, status = Open3::capture2e(cmd)
  puts((status.success? ? 'success.' : 'failed!')) if verbose

  raise "failed execution of '#{cmd}': #{out}'" unless status.success?

  status.success?
end

all_keys = NsdKey::read_metadata(options[:metadata], verbose)

undeprecated_keys = all_keys.reject(&:deprecated?)

if undeprecated_keys.empty?
  puts 'no undeprecated keys found, generating ... ' if verbose
  params = NsdKey::key_params(
    validity_period: options[:period],
    overlap_period: options[:overlap],
    algorithm: options[:algorithm]
  )
  key = NsdKey::gen(
    directory: options[:directory],
    domain: domain,
    key_params: params,
    verbose: verbose
  )
  all_keys << key
elsif verbose
  puts "#{undeprecated_keys.length} valid keys found"
end

unexpired_keys = all_keys.reject(&:expired?)
NsdKey::write_metadata(unexpired_keys, options[:metadata], verbose)

expired_keys = all_keys.select(&:expired?)

expired_keys.each do |k|
  k.delete(verbose)
end

puts 'key rotation complete!' if verbose
