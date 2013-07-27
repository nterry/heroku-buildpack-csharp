class BuildPack

  def self.detect
    sln_files = Dir.glob('*.sln')
    raise if sln_files.empty?
    return 'C#'
  end

  def self.prepare

  end
end