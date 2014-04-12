# Manage user transfer uploads and downloads
class TransfersController < Controller

  attr_reader :downloads
  attr_reader :uploads

  attr_writer :stream

  # Request a file from a contact
  #
  # *file* filename to download
  # *to*   JID of the contact
  def request(file, to)
    return unless available?
    to = Jabber::JID.new(to) unless to.class == Jabber::JID

    iq = IqFileTransfer.new(file, to)
    @stream.send iq
  end

  # Reset all downloads and uploads
  def reset
    @uploads = Array.new
    @downloads = Array.new

    Log4r::Logger['app'].info 'Reset uploads and downloads'
    changed
    notify_observers
  end

  # Clear all finished downloads and uploads
  def clear_finished
    @uploads.delete_if {|upload| upload.state == :finish}
    @downloads.delete_if {|download| download.state == :finish}

    Log4r::Logger['app'].info 'Clear finished uploads and downloads'
    changed
    notify_observers
  end

  # Observe uploads and downloads when their states changed
  def update
    changed
    notify_observers
  end

  # Set the stream of this controller
  #
  # *stream*:: A Jabber::Client to use
  def stream=(stream)
    @stream = stream
    reset

    if available?
      start_listening_incoming_files
      start_listening_requests
    else
      @transferer = nil
    end
  end

  # Test if this controller is ready
  #
  # *_return_*:: True if the controller is ready
  def available?
    (@stream)? true : false
  end

private

  # Listener when a contact send a file
  #
  # Accept the request and start downloading the file
  def start_listening_incoming_files
    @transferer = Jabber::FileTransfer::Helper.new @stream

    @transferer.add_incoming_callback do |iq,file|
      Log4r::Logger['app'].info "Accept '#{file.fname}' from #{iq.from}"

      begin
        Thread.new do
          begin
            file_stream = @transferer.accept iq
            download = Download.new(file, iq.from)
            @downloads << download
            download.add_observer self
            download.start file_stream
          rescue
            Log4r::Logger['app'].error "Listening incoming file: #{$!.to_log}"
          end
        end
      end
    end
  end

  # Listener when a contact request for one of user file
  #
  # Don't send a IQ result but send the file
  def start_listening_requests
    @stream.add_iq_callback do |iq|
      begin
        if iq.query and iq.query.namespace == QueryFileTransfer::NAMESPACE
          if iq.type == :get
            Thread.new do
              file = iq.first_element_text 'file'
              send(file, iq.from)
            end
          end
        end
      rescue
        Log4r::Logger['app'].error "Listening outcoming file :#{$!.to_log}"
      end
    end
  end

  # Send a file to a contact
  #
  # *file* filename to download
  # *to*   JID of the contact
  def send(file, to)
    return unless available?

    begin
      filepath = @app.collection_controller.path file

      upload = Upload.new(filepath, to)
      @uploads << upload
      upload.add_observer self
      upload.start(@transferer, proxies())
    rescue
      Log4r::Logger['app'].error "Sending #{file.to_s} to #{to.to_s} :#{$!.to_log}"
    end
  end

  # Return all proxies available
  #
  # *_return_* An array of String proxy hostname
  def proxies
    servers = Conf.instance.params['proxies']
  end

end
