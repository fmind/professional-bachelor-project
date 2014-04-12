# Give information about a Jabber node (client, server, service)
class ServicesController < Controller

  attr_writer :stream

  # Test if a server has a proxy
  #
  # *jid*:: The server JID
  # *_return_*:: True if the server has a proxy
  def has_proxy?(jid)
    return unless available?

    Log4r::Logger['app'].info "Query if #{jid} server has a proxy"

    items = @discoverer.get_items_for jid.domain
    items.each do |item|
      return item.jid.domain if item.jid.domain =~ /^proxy/
    end

    false
  end

  # Test if a server has a pubsub server
  #
  # *jid*:: The server JID
  # *_return_*:: True if the server has a pubsub service
  def has_pubsub?(jid)
    return unless available?

    Log4r::Logger['app'].info "Query if #{jid} server has a pubsub"

    items = @discoverer.get_items_for jid.domain
    items.each do |item|
      return item.jid if item.jid.domain =~ /^pubsub/
    end

    false
  end

  # Set the stream of this controller
  #
  # *stream*:: A Jabber::Client to use
  def stream=(stream)
    @stream = stream

    if available?
      @discoverer = Jabber::Discovery::Helper.new @stream
    else
      @discoverer = nil
    end
  end

  # Test if this controller is ready
  #
  # *_return_*:: True if the controller is ready
  def available?
    (@stream)? true : false
  end
end