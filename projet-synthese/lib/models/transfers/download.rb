# Represent a download from a contact
#
# read a file stream and write the content in a file
class Download < Transfer
  attr_reader :destination
  attr_reader :from

  States = [:new, :download, :finish]

  # *file* xmpp4r destination file
  # *from* JID of the contact
  def initialize(file, from)
    @from = from
    @destination = file
    self.state = :new
    Log4r::Logger['app'].info "New download #{@destination.fname} from #{@from}"
  end

  # Start the download
  # timeout of 30 sec before cancel this download
  def start(file_stream)
    @file_stream = file_stream
    @file_stream.connect_timeout = 30
    download
  end

private

  # Download the file
  def download
   unless valid_streamhosts
    raise "Download stream for #{@destination.fname} to #{@from} failed"
   end

    path = [$APP_ROOT, "downloads", @destination.fname].join '/'
    file = File.open(path, 'w')

    self.state = :downloading
    Log4r::Logger['app'].info "Downloading #{path} from #{@from}"

    while buffer = @file_stream.read(1024) and not buffer.empty?
      file.write buffer
    end

    file.close
    @file_stream.close
    self.state = :finish
    Log4r::Logger['app'].info "Finish downloading #{path} from #{@from}"
  end

  # Find a valid streamhost used as a proxy
  #
  # *_return_* true if a valid streamhost was found
  def valid_streamhosts
    @file_stream.add_streamhost_callback do |streamhost, state, err|
      case state
      when :success
        Log4r::Logger['app'].info "Use #{streamhost} proxy for downloading #{@destination.fname}"
      when :failure
        Log4r::Logger['app'].info "Cannot use #{streamhost} for downloading #{@destination.fname}: #{err}"
      end
    end

    @file_stream.accept
  end
end