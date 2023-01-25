# frozen_string_literal: true

require 'open3'
require 'optparse'
require 'tmpdir'

options = {
  verbose: false
}

OptionParser.new do |opts|
  opts.banner = "usage: #{File::basename $PROGRAM_NAME} [options]"

  opts.on('-c', '--config-file CONFIG', 'KDC config file.') do |conf|
    options[:conf] = conf
  end

  opts.on('-o', '--output OUTPUT_DATABASE', 'Output database in converted format.') do |output|
    options[:output] = output
  end

  opts.on('-k', '--key KEY_FILE', 'Realm key for decrypting/encrypting the database.') do |key|
    options[:key] = key
  end

  opts.on('-F', '--format FORMAT', 'Database format for output database.') do |format|
    options[:format] = format
  end

  opts.on('-r', '--realm REALM', 'Kerberos realm of database.') do |realm|
    options[:realm] = realm
  end

  opts.on('-h', '--help', 'Display this message.') do
    puts opts
    exit(0)
  end
end.parse!

raise "missing required parameter: CONFIG" unless options[:conf]

raise "missing required parameter: OUTPUT_DATABASE" unless options[:output]

raise "missing required parameter: KEY" unless options[:key]

raise "missing required parameter: FORMAT" unless options[:format]

raise "missing required parameter: REALM" unless options[:realm]

verbose = options[:verbose]

def exec!(verbose, msg, cmd)
  puts msg if verbose
  print "  $ #{cmd} ... " if verbose
  out, status = Open3::capture2e(cmd)
  puts((status.success? ? 'success.' : 'failed!')) if verbose

  raise "failed execution of '#{cmd}': #{out}" unless status.success?

  status.success?
end

# rubocop:disable Metrics/MethodLength
def generate_kdc(format, realm, db, key, out)
  data = <<~KDC_CONF
    [kdc]
      database = {
        realm = #{realm}
        dbname = #{format}:#{db}
        mkey_file = #{key}
        log_file = /dev/null
      }

    [libdefaults]
      default_realm = #{realm}
      allow_weak_crypto = false

    [logging]
      default = CONSOLE
  KDC_CONF
  File::write(out, data)
  out
end
# rubocop:enable Metrics/MethodLength

def dumpdb(verbose, conf, out)
  exec!(verbose, "dumping database ...",
        ["kadmin",
         "--local",
         "--config-file=#{conf}",
         "--",
         "dump",
         "--decrypt",
         out].join(' '))
end

def loaddb(verbose, conf, dumpfile)
  exec!(verbose, "loading database ...",
        ["kadmin",
         "--local",
         "--config-file=#{conf}",
         "--",
         "load",
         dumpfile].join(' '))
end

Dir::mktmpdir("kdc-connert") do |tmpdir|
  dumpfile = "#{tmpdir}/realm.dump"
  dumpdb(verbose, options[:conf], dumpfile)
  out_conf = generate_kdc(options[:format],
                          options[:realm],
                          options[:output],
                          options[:key],
                          "#{tmpdir}/kdc.conf")
  loaddb(verbose, out_conf, dumpfile)
end
