# Interface to tmc-javalib
module TmcJavalib
  def self.project_path
    "#{::Rails.root}/lib/tmc-javalib"
  end

  def self.jar_path
    "#{project_path}/dist/tmc-javalib.jar"
  end
  
  def self.compiled?
    File.exists? jar_path
  end
  
  def self.compile!
    Dir.chdir(project_path) do
      output = `ant -q jar`
      raise "Failed to compile javalib\n#{output}" unless $?.success?
    end
  end
end
