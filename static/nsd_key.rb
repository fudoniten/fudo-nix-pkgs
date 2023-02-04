# frozen_string_literal: true

require 'tmpdir'
require 'date'
require 'json'

def keys_to_date(hsh, keys)
  keys.each_with_object(hsh) do |k, h|
    h[k] = Date::parse(h[k])
  end
end

# rubocop:disable Metrics/ClassLength

# Represents a ZSK for NSD
class NsdKey
  attr_reader :name, :public_key, :private_key

  def initialize(public_key:, private_key:, valid_date:, expiry_date:, deprecation_date:)
    @name = File::basename(public_key, '.*')
    @public_key = public_key
    @private_key = private_key
    @valid = valid_date
    @expiry = expiry_date
    @deprecation = deprecation_date
  end

  def self.gen_key(dir, algo, domain, verbose = false)
    Dir::mktmpdir do |d|
      Dir::chdir(d) do
        exec!(verbose, 'generate zone-signing key (zsk) ... ', "ldns-keygen -a #{algo} #{domain}")
        pubkey = File::basename Dir["#{d}/*.key"].first
        privkey = File::basename Dir["#{d}/*.private"].first
        FileUtils::mv("#{d}/#{pubkey}", "#{dir}/#{pubkey}")
        FileUtils::mv("#{d}/#{privkey}", "#{dir}/#{privkey}")
        { public: "#{dir}/#{pubkey}", private: "#{dir}/#{privkey}" }
      end
    end
  end

  def self.key_params(validity_period:, overlap_period:, algorithm:)
    {
      validity_period: validity_period,
      overlap_period: overlap_period,
      algorithm: algorithm
    }
  end

  def self.gen(directory:, domain:, key_params:, verbose: false)
    key = gen_key(directory, key_params[:algorithm], domain, verbose)
    validity, overlap = key_params.fetch_values(:validity_period, :overlap_period)
    expiry = Date::today + validity
    deprecation = Date::today + (validity - overlap)
    new(public_key: key[:public],
        private_key: key[:private],
        valid_date: Date::today,
        expiry_date: expiry,
        deprecation_date: deprecation)
  end

  def to_hash
    {
      public_key: @public_key,
      private_key: @private_key,
      valid_date: @valid,
      expiry_date: @expiry,
      deprecation_date: @deprecation
    }
  end

  def self.from_hash(hash)
    new(**hash)
  end

  def self.read_metadata_file(mdfile, verbose = false)
    puts "reading key metadata from #{mdfile}" if verbose
    File::open(mdfile, 'r') do |file|
      raw_data = JSON::parse(file.read, { symbolize_names: true })
      data = raw_data.map { |k| keys_to_date(k, %i[valid_date expiry_date deprecation_date]) }
      data.map { |k| from_hash(k) }
    end
  end

  def self.read_metadata(metadata, verbose = false)
    all_keys = File::exist?(metadata) ? read_metadata_file(metadata) : []
    puts " ... #{all_keys.length} keys found" if verbose
    all_keys
  end

  def self.gen_metadata(keys, verbose = false)
    puts ' ... generating metadata' if verbose
    key_data = keys.map(&:to_hash)
    JSON::pretty_generate(key_data)
  end

  def self.write_metadata_file(keys, mdfile, verbose = false)
    md = gen_metadata(keys, verbose)
    puts " ... writing metadata to file #{mdfile}" if verbose
    File::open(mdfile, 'w') do |file|
      file.write(md)
    end
  end

  def self.write_metadata(keys, metadata, verbose = false)
    puts "saving metadata for #{keys.length} keys to #{metadata}" if verbose
    Dir::mktmpdir do |tmpdir|
      mdfile = "#{tmpdir}/metadata.json"
      write_metadata_file(keys, mdfile, verbose)
      puts " ... moving to #{metadata}" if verbose
      FileUtils::mv(mdfile, metadata)
    end
  end

  def delete(verbose = false)
    puts "deleting expired key: #{@name}" if verbose
    puts " ... private key: #{@private_key}" if verbose
    FileUtils::rm(@private_key)
    puts " ... public key: #{@public_key}" if verbose
    FileUtils::rm(@public_key)
    puts ' ...done.'
  end

  def valid?
    today = Date::today
    @valid <= today && @expiry > today
  end

  def deprecated?
    @deprecation < Date::today
  end

  def expired?
    @expiry < Date::today
  end
end

# rubocop:enable Metrics/ClassLength
