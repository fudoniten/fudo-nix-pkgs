
require 'tmpdir'
require 'date'
require 'json'

class NsdKey
  attr_reader :public_key, :private_key

  def initialize(public_key:, private_key:, valid_date:, expiry_date:, deprecation_date:)
    @public = public_key,
    @private = private_key,
    @valid = valid_date,
    @expiry = expiry_date
    @deprecation = deprecation_date
  end

  def self.gen_key(dir, algo, domain)
    Dir::mktmpdir do |d|
      Dir::chdir(d) do
        exec!(verbose, 'generate zone-signing key (zsk) ... ',
              "ldns-keygen -a #{algo} #{domain}")

        pubkey = File::basename Dir["#{d}/*.key"].first
        privkey = File::basename Dir["#{d}/*.private"].first
        FileUtils::mv("#{d}/#{pubkey}", "#{dir}/#{pubkey}")
        FileUtils::mv("#{d}/#{privkey}", "#{dir}/#{pubkey}")
        { public: "#{dir}/#{pubkey}", private: "#{dir}/#{privkey}" }
      end
    end
  end

  def self.gen(directory:, algorithm:, domain:, validity_period:, overlap_period:)
    keys = self.gen_key(directory, algorithm, domain)
    self.new(public_key: keys[:public],
             private_key: keys[:private],
             valid_date: Date::today,
             expiry_date: Date::today + validity_period,
             deprecation_date: Date::today + (validity_period - overlap_period))
  end

  def to_hash
    {
      public_key: @public,
      private_key: @private,
      valid_date: @valid,
      expiry_date: @expiry,
      deprecation_date: @deprecation
    }
  end

  def from_hash(hash)
    self.new(hash)
  end

  def self.read_keys(metadata, verbose = false)
    puts "reading key metadata from #{metadata}" if verbose
    all_keys = []
    if File::exist?(metadata)
      File::open(options[:metadata], 'r') do |file|
        all_keys = JSON::parse(file.read).map { |k| self.from_hash(k) }
      end
    end
    puts " ... #{all_keys.length} keys found" if verbose
    all_keys
  end

  def self.write_keys(keys, metadata, verbose = false)
    puts "saving metadata for #{keys.length} keys to #{metadata}" if verbose
    Dir::mktmpdir do |tmpdir|
      mdf = "#{tmpdir}/metadata.json"
      puts " ... generating metadata" if verbose
      key_data = keys.map { |k| k.to_hash }
      json_data = JSON::generate(key_data)
      puts " ... saving to temporary file #{mdf}" if verbose
      File::open(mdf, 'w') do |file|
        file.write(json_data)
      end
      puts " ... moving to #{metadata}" if verbose
      FileUtils::mv(mdf, metadata)
    end
  end

  def valid?
    today = Date::today
    @valid >= today && @expiry < today
  end

  def deprecated?
    @deprecated < Date::today
  end

  def expired?
    @expiry < Date::today
  end
end
