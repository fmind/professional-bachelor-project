# Access to application configuration
# Store only one file

class Conf
  include Singleton

  attr_reader :params

  # Initialize the configuration file
  #
  # *conf_file*:: configuration file path
  def init(conf_file)
    unless File.exists? conf_file
      raise "Error: configuration file #{conf_file} not exist"
    end

    @params = YAML::load File.open(conf_file)
  end
end