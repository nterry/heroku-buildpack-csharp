require_relative '../language_pack'
require 'pathname'
require 'yaml'
require 'digest/sha1'
require 'iron-spect'

Encoding.default_external = Encoding::UTF_8 if defined?(Encoding)

# abstract class that all the Ruby based Language Packs inherit from
class LanguagePack::Mono


  VENDOR_URL = 'https://s3.amazonaws.com/heroku-buildpack-ruby'

  attr_reader :build_path, :cache_path, :project_inspector


  def initialize(build_path, cache_path=nil)
    @build_path = build_path
    @cache_path = cache_path
    @id = Digest::SHA1.hexdigest("#{Time.now.to_f}-#{rand(1000000)}")[0..10]
    @project_inspector = IronSpect::Inspecter.new(build_path)
    Dir.chdir build_path
  end


  def self.===(build_path)
    raise 'must subclass'
  end


  def name
    'C#'
  end


  def default_addons
    raise 'must subclass'
  end


  def default_config_vars
    base_path = "/app/vendor/mono/#{self.class.to_s.split('::').last.downcase}"
    { 'PATH' => "#{base_path}/bin", 'CPATH' => "#{base_path}/include", 'CPPPATH' => "#{base_path}/include" }
  end


  def default_process_types
    raise 'must subclass'
  end

  # this is called to build the slug
  def compile
    raise 'must subclass'
  end


  def release
    setup_language_pack_environment
    {
        'addons' => default_addons,
        'config_vars' => default_config_vars,
        'default_process_types' => default_process_types
    }.to_yaml
  end


  def log(*args)
    args.concat [:id => @id]
    args.concat [:framework => self.class.to_s.split('::').last.downcase]

    start = Time.now.to_f
    log_internal args, :start => start

    if block_given?
      begin
        ret = yield
        finish = Time.now.to_f
        logg args, :status => 'complete', :finish => finish, :elapsed => (finish - start)
        return ret
      rescue StandardError => ex
        finish = Time.now.to_f
        logg args, :status => 'error', :finish => finish, :elapsed => (finish - start), :message => ex.message
        raise ex
      end
    end
  end

  private

  # sets up the environment variables for the build process
  def setup_language_pack_environment
  end

  def logg(*args)
    log_console args
    log_internal args
  end

  def log_console(*args)
    message = build_log_message args
    puts message
  end


  def log_internal(*args)
    message = build_log_message(args)
    %x{ logger -p user.notice -t "slugc[$$]" "buildpack-csharp #{message}" }
  end


  def build_log_message(args)
    args.map do |arg|
      case arg
        when Float then '%0.2f' % arg
        when Array then build_log_message(arg)
        when Hash  then arg.map { |k,v| "#{k}=#{build_log_message([v])}" }.join(' ')
        else arg
      end
    end.join(' ')
  end


  def error(message)
    Kernel.puts ' !'
    message.split("\n").each do |line|
      Kernel.puts " !     #{line.strip}"
    end
    Kernel.puts ' !'
    log 'exit', :error => message
    exit 1
  end

  def warn(message)
    message.split("\n").each do |line|
      Kernel.puts " W:    #{line.strip}"
    end
  end

  def info(message)
    message.split("\n").each do |line|
      Kernel.puts " I:    #{line.strip}"
    end
  end


  def run(command)
    %x{ #{command} 2>&1 }
  end


  def run_stdout(command)
    %x{ #{command} 2>/dev/null }
  end


  def pipe(command)
    output = ''
    IO.popen(command) do |io|
      until io.eof?
        buffer = io.gets
        output << buffer
        puts buffer
      end
    end

    output
  end


  def topic(message)
    Kernel.puts "-----> #{message}"
    $stdout.flush
  end


  def puts(message)
    message.split("\n").each do |line|
      super "       #{line.strip}"
    end
    $stdout.flush
  end


  def cache_base
    Pathname.new(cache_path)
  end


  def cache_clear(path)
    target = (cache_base + path)
    target.exist? && target.rmtree
  end


  def cache_store(path, clear_first=true)
    cache_clear(path) if clear_first
    cache_copy path, (cache_base + path)
  end


  def cache_load(path)
    cache_copy (cache_base + path), path
  end


  def cache_copy(from, to)
    return false unless File.exist?(from)
    FileUtils.mkdir_p File.dirname(to)
    system("cp -a #{from}/. #{to}")
  end

  def download_mono
    run("curl #{MONO_BASE_URL}/#{MONO_VERSION}.tgz -s -o - | tar xzf -")
  end

  def dot_monoproperties
    YAML.load_file('.monoproperties').to_sym if File.exist? '.monoproperties'
  end

end

class Hash

  def to_sym
    convert_hash_to_use_symbols self
  end

  private

  def convert_hash_to_use_symbols(hash)
    hash.inject({}) do |memo, (k,v)|
      if v.is_a?(Hash)
        memo[k.to_sym] = convert_hash_to_use_symbols(v)
      elsif v.is_a?(Array)
        memo[k.to_sym] = v.map do |x|
          if x == nil or (not x.is_a?(Hash) and not x.is_a?(Array))
            x
          else
            convert_hash_to_use_symbols(x)
          end
        end
      else
        memo[k.to_sym] = v
      end
      memo
    end
  end

end
