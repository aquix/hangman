require 'yaml'

class SaveManager
  def self.save(filename, object)
    File.write filename, YAML.dump(object)
  end

  def self.load(filename)
    YAML.load File.read(filename)
  end

end
