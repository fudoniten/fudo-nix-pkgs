# frozen_string_literal: true

require 'open3'
require 'optparse'

options = {
  generate_keys: %w[deploy host initrd],
  key_types: %w[ecdsa],
  overwrite: false,
  verbose: false
}

OptionParser.new do |opts|
  opts.on('-h', '--help', 'Print this message.') {
    puts "usage: #{File::basename $PROGRAM_NAME} [opts] <hostname>"
    puts opts
    exit(0)
  }

  opts.on('-t', '--key-types TYPE0,TYPE1', 'Key types to generate (comma-separated).') { |types|
    options[:key_types] = types.split(',')
  }

  opts.on('-o', '--output-path OUTPUT_PATH', 'Path at which to generate host keys.') { |path|
    options[:output_path] = path
  }

  opts.on('-k', '--generate-keys KEYS', 'Types of host keys to generate.') { |keys|
    options[:generate_keys] = keys.split(',')
  }

  opts.on('-d', '--overwrite', 'Overwrite existing keys.') {
    options[:overwrite] = true
  }

  opts.on('-v', '--verbose', 'Provide verbose output.') {
    options[:verbose] = true
  }
end.parse!

verbose = options[:verbose]

if options[:output_path]
  output_path = options[:output_path]
elsif ENV.key? 'SSH_KEY_OUTPUT_PATH'
  output_path = ENV['SSH_KEY_OUTPUT_PATH']
else
  throw 'Missing required argument: OUTPUT_PATH'
end

throw "Path does not exist: #{output_path}" unless File::directory?(output_path)

if ARGV.length == 1
  hostname = ARGV[0]
else
  throw 'Missing hostname argument.'
end

def exec!(verbose, msg, cmd)
  puts msg if verbose
  print "  $ #{cmd} ... " if verbose
  out, status = Open3::capture2e(cmd)
  puts((status.success? ? 'success.' : 'failed!')) if verbose

  raise "failed execution of '#{cmd}': #{out}'" unless status.success?

  status.success?
end

puts "Generating keys for host #{hostname} ... " if verbose

options[:generate_keys].each do |gen_key|
  out_path = "#{output_path}/#{gen_key}"
  Dir::mkdir(out_path) unless File::directory?(out_path)
  options[:key_types].each do |key_type|
    filename = "#{out_path}/#{hostname}.#{key_type}.key"
    if File::exist?(filename) && !options[:overwrite]
      puts "  ... skipping, file exists: #{filename}"
      next
    end
    exec!(verbose, "  ... #{key_type} key at #{filename} ...",
          "ssh-keygen -q -N \"\" -t #{key_type} -f #{filename}")
  end
end
