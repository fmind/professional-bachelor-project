# = Core class of Pr2Pr application
#
# This class manage:
# * Controllers
# * Main windows
# * Uncatched exceptions
# * Log and configuration classes
# * Application arguments
#
class Pr2Pr < Wx::App

  ## Controllers
  attr_reader :accounts_controller
  attr_reader :roster_controller
  attr_reader :collection_controller
  attr_reader :transfers_controller
  attr_reader :services_controller

  ## Application parameters
  # Debug mode
  attr_accessor :debug
  # No user interface mode
  attr_accessor :nox

  # Initialize the application
  def initialize
    super

    set_app_name 'Pr2Pr'
    @debug = false
    @nox = false

    init_conf
    init_log
    init_controllers
  end

  # Called after the initialize
  def on_init
    Log4r::Logger['app'].info "Initialize the application at: #{Time.now}"
    parse_opts
  rescue
    Log4r::Logger['app'].error "Error on init: #{$!.to_log}"
  end

  # Call before running the application
  def on_run
    update
    super

    Log4r::Logger['app'].info "Run the application at: #{Time.now}"
  rescue
    Log4r::Logger['app'].error "Error on run: #{$!.to_log}"
    retry
  end

  # Called when user quit the application
  def on_quit
    Log4r::Logger['app'].info "Close the application at: #{Time.now}"
    super
  end

  # Observer method, update windows and the stream
  def update
    stream = @accounts_controller.stream

    # Reset observers
    @accounts_controller.delete_observers
    @services_controller.delete_observers
    @roster_controller.delete_observers
    @collection_controller.delete_observers
    @transfers_controller.delete_observers

    @accounts_controller.add_observer self

    # Order is important !
    unless @nox
      if stream
        set_window MainFrame.new
      else
        set_window ConnectionFrame.new
      end
    end

    @services_controller.stream = stream
    @roster_controller.stream = stream
    @collection_controller.stream = stream
    @transfers_controller.stream = stream
  end

private

  # Set the active window, only one show to the user
  #
  # *window*:: The window to set active
  def set_window(window)
    @main_window.destroy if @main_window

    @main_window = window
    set_top_window @main_window
    @main_window.show
  end

  # Parse command line arguments
  def parse_opts
    OptionParser.new do |opts|
      opts.banner = 'Usage: Pr2Pr.rb [options]'

      opts.on('-d', '--pr2pr-debug', 'Debug for pr2pr only') do
        @debug = true
      end

      opts.on('-n', '--nox', 'Running without interface') do
        @nox = true
      end

      opts.on('-h', '--help', 'you are looking it') do
        puts opts
        exit 0
      end

      opts.parse! ARGV
    end
  end

  # Initialize configuration classes
  def init_conf
    conf = Conf.instance.init "#{$APP_ROOT}/conf/default.yml"
  end

  # Initialize log classes
  def init_log
    log = Log4r::YamlConfigurator
    log['LOG_DIR'] = "#{$APP_ROOT}/log"
    log.load_yaml_file "#{$APP_ROOT}/conf/log.yml"
    Log4r::Outputter['stderr'].level = Log4r::DEBUG if @debug
  end

  # Initialize application controllers
  def init_controllers
    # Order is important !
    # Ex: roster controller need accounts controller

    @accounts_controller = AccountsController.new self
    @services_controller = ServicesController.new self
    @roster_controller = RosterController.new self
    @collection_controller = CollectionController.new self
    @transfers_controller = TransfersController.new self

    # Pr2Pr follow accounts controller modifications
    @accounts_controller.add_observer self
  end

end
