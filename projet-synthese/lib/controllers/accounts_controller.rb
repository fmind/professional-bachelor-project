# Manage user account
class AccountsController < Controller

  attr_reader :jid
  attr_reader :stream

  # Create an account
  # After calling this method, application is not connected
  #
  # *jid*:: JID of the new user
  # *password*:: Account password of the new user
  def create(jid, password)
    jid = Jabber::JID.new jid
    stream = Jabber::Client.new jid

    begin
      stream.connect
    rescue
      Log4r::Logger['app'].error "Cannot connect: #{$!.to_log}"
      raise "Unable to connect to #{jid.domain}"
    end

    begin
      stream.register password
    rescue
      Log4r::Logger['app'].error "Cannot register: #{$!.to_log}"
      raise "Unable to register to #{jid.domain}"
    end

    stream.close
    Log4r::Logger['app'].info "Create account #{jid}"
  end

  # Connect the user
  #
  # *jid*:: User jid, force resource to 'Pr2Pr'
  # *password*:: User password
  def connect(jid, password)
    @jid = Jabber::JID.new jid
    @jid.resource = 'Pr2Pr'

    begin
      @stream = Jabber::Client.new @jid
      @stream.connect
    rescue
      Log4r::Logger['app'].error "Cannot connect #{$!.to_log}"
      raise "Unable to connect to #{@jid.domain}"
    end

    begin
      @stream.auth password
      Log4r::Logger['app'].info "Connect #{@jid}"
    rescue
      Log4r::Logger['app'].error "Cannot authentificate #{$!.to_log}"
      raise "Unknown jid or wrong password"
    end

    changed
    notify_observers
  end

  # Disconnect the user
  def disconnect
    return unless @stream

    @stream.close
    @stream = nil
    Log4r::Logger['app'].info "Disconnect #{@jid}"
    @jid = nil

    changed
    notify_observers
  end

  # Delete the user account permanently then disconnect him
  def delete
    return if @stream.is_disconnected? or @stream.nil?

    begin
      @stream.remove_registration
    rescue
      Log4r::Logger['app'].error "Cannot remove account #{$!.to_log}"
      raise "Unable to remove account #{@jid}"
    end

    Log4r::Logger['app'].info "Delete account #{@jid}"
    disconnect
  end
end
