# Manage the user file collection
# - Store the file name on a server pubsub node
# - Store an association file name => path on a local database
class CollectionController < Controller
  attr_writer :stream

  # Add a file to the collection
  #
  # *path*:: Path of the file
  def add(path)
    return unless available?
    raise 'File not exists' unless File.exists? path

    path = File.expand_path path
    filename = File.basename path

    @database.transaction { @database[filename] = path }

    changed
    notify_observers
    Log4r::Logger['app'].info "Add file: '#{path}' to collection"
  end

  # Delete a file to the collection
  #
  # *path*:: Path of the file
  def delete(path)
    return unless available?
    raise 'File not in collection' unless filenames.include? File.basename(path)

    filename = File.basename path

    @database.transaction do
      @database.delete filename
    end

    changed
    notify_observers
    Log4r::Logger['app'].info "Delete file: '#{path}' to collection"
  end

  # Return all files in local database
  #
  # *_return_*:: An array of String file path
  def filepaths
    return unless available?

    files = Array.new
    @database.transaction(true) do
      @database.roots.each { |id| files << @database[id] }
    end

    files
  end

  # Return all files in local database
  #
  # *_return_*:: An array of String file name
  def filenames
    return unless available?

    files = Array.new
    @database.transaction(true) do
      @database.roots.each { |id| files << id }
    end

    files
  end

  # Return a path given a filname
  #
  # *filename*:: Base name of the file
  #
  # *_return_*:: Full path of a file name
  def path(filename)
    return unless available?

    @database.transaction(true) do
      @database.roots.each do |id|
        return @database[id] if id == filename
      end
    end

    nil
  end

  # Retrieve all files in contact's collection
  #
  # *jid*:: The contact JID
  #
  # *_return_*:: A list of Jabber::PubSub::Item
  def contact_files(jid)
    return unless available?

    files = Array.new
    contact_files_iq = IqContactFiles.new jid
    @stream.send_with_id(contact_files_iq) do |reply|
      begin
        if reply.query and reply.query.namespace == QueryContactFiles::NAMESPACE
          reply.each_element('file') do |file|
            files << file.text
          end
        end
      rescue
        Log4r::Logger['app'].error "Error while receiving #{reply.jid}contact files: #{$!.to_log}"
      end
    end

    files
  end

  # Set the stream of this controller
  #
  # *stream*:: A Jabber::Client to use
  def stream=(stream)
    @stream = stream

    if available?
      @database = PStore.new "#{$APP_ROOT}/database/#{stream.jid.bare}.pstore"
      start_listening_requests
    else
      @database = nil
    end

    changed
    notify_observers
  end

  # Test if this controller is ready
  #
  # *_return_*:: True if the controller is ready
  def available?
    (@stream)? true : false
  end

private
  # Listener when one of your contact want to read your file collection
  #
  # Send a IqResult with all your collection files
  def start_listening_requests
    @stream.add_iq_callback do |iq|
      begin
        if iq.query and iq.query.namespace == QueryContactFiles::NAMESPACE
          if iq.type == :get
            files = filenames
            res = IqResContactFiles.new(files, iq)
            @stream.send res
          end
        end
      rescue
        Log4r::Logger['app'].error "Listening contact files :#{$!.to_log}"
      end
    end
  end
end
