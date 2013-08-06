require_relative '../language_pack'
require_relative 'mono'

class LanguagePack::Mono2 < LanguagePack::Mono
  MONO_BASE_URL        = 'https://s3.amazonaws.com/mono-bin'
  MONO_VERSION         = 'mono2/mono-2.10.8.1'

  def self.use?
    false if Dir.glob('*.sln').empty?
    if File.exist? '.monoproperties'
      file = YAML.load_file('.monoproperties').to_sym
      file[:runtime][:version].scan(/(\d+)\.?/)[0][0] == '2' if file[:runtime][:version]
    end
    true
  end

  # list of default addons to install
  def default_addons
    {}
  end


  def default_config_vars
    super.merge!({'PATH' => 'project_output_dir'}) { |key, oldval, newval| (key === 'PATH') ? "#{newval}:#{oldval}" : newval }
  end


  def default_process_types
    { 'web' => 'mono CROWBAR.exe $PORT' }
  end

  # this is called to build the slug
  def compile
    Dir.chdir @build_path
    topic 'Begin compilation'
    log 'Compiling...' do
      sln_files = if (not (dot_monoproperties)) then
                    Dir.glob('*.sln')
                  else
                    (dot_monoproperties[:build][:sln] && File.exist?("#{dot_monoproperties[:build][:sln]}.sln")) ? %W(#{dot_monoproperties[:build][:sln]}.sln) : []
                  end
      error 'No solution files found' if sln_files.empty?
      info "More than one Solution file found. Building #{sln_files.first} only. (Override this by specifying a sln file in '.monoproperties')" if sln_files.length > 1

    end
  end

  private

  def prepare_compile
    run "export PATH=#{default_config_vars['PATH']}:$PATH"
    configuration = (dot_monoproperties[:build][:target] =~ /^(Debug|Release)\|(AnyCPU|x86|x64|Itanium)$/) ? dot_monoproperties[:build][:target].split('|').first : 'Debug'
    startup_project = (dot_monoproperties[:deploy][:startup_project]) ? dot_monoproperties[:deploy][:startup_project] : '<FIRST PROJECT IN SLN FILE (THE DEFAULT BEHAVIOUR)>'
    @project_inspector.get_executable_path(configuration)
  end
end