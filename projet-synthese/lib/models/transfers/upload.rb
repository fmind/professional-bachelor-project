# Represent an upload to a contact
#
# open a file stream and send the file
class Upload < Transfer
  attr_reader :source
  attr_reader :to

  States = [:new, :offer, :accepted, :refused, :uploading, :finish]

  # *filepath* filepath String of the file to send
  # *to* JID of the contact
  def initialize(filepath, to)
    raise 'File not exists' unless File::exists? filepath

    @source = Jabber::FileTransfer::FileSource.new filepath
    @to = Jabber::JID.new to
    self.state = :new
    Log4r::Logger['app'].info "New upload #{@source.filename} to #{@to}"
  end

  # Start the stream
  #
  # *transferer* Xmpp4r TransferHelper to help manage the transfer
  # *proxies* an array of hostname String use to open file stream
  def start(transferer, proxies)
    @transferer = transferer
    @proxies = proxies
    offer
  end

  private

  # Offer the file to a contact a wait he accepts it
  # upload if the contact accepts the file
  def offer
    self.state = :offer
    Log4r::Logger['app'].info "Offer #{@source.filename} to #{@to}"
    @file_stream = @transferer.offer(@to, @source, 'Pr2Pr upload')

    if @file_stream
      self.state = :accepted
      Log4r::Logger['app'].info "#{@to} accepts #{@source.filename}"
      upload
    else
      self.state = :refused
      Log4r::Logger['app'].info "#{@to} refuses #{@source.filename}"
    end
  end

  # Upload the file by reading the file and write it in the file stream
  def upload
    self.state = :uploading
    Log4r::Logger['app'].info "Upload #{@source.filename} to #{@to}"
    find_streamhost
    @file_stream.open

    while buffer = @source.read
      @file_stream.write buffer
      @file_stream.flush
    end

    @file_stream.close
    self.state = :finish
    Log4r::Logger['app'].info "Finish uploading #{@file_path} to #{@to}"
  end

  # Find stream hosts to proxy the transfer
  def find_streamhost
    @proxies.each {|proxy| @file_stream.add_streamhost proxy}

    @file_stream.add_streamhost_callback do |streamhost, state, err|
      case state
      when :success
        Log4r::Logger['app'].info "Use #{streamhost} proxy for uploading #{@source.filename}"
      when :failure
        Log4r::Logger['app'].info "Cannot use #{streamhost} for uploading #{@source.filename}: #{err}"
      end
    end
  end
end
