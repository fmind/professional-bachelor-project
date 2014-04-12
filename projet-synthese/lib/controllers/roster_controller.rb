# Manage the user contacts and groups or roster
class RosterController < Controller

  attr_writer :stream

  # Add a contact to the user roster
  #
  # *jid*:: JID of the contact
  def add(jid)
    return unless available?
    jid = Jabber::JID.new jid unless jid.class == Jabber::JID

    @roster.add(jid, jid.node, true)
    Log4r::Logger['app'].info "Add contact #{jid}"

    changed
    notify_observers
  end

  # Remove a contact to the user roster
  #
  # *jid*:: JID of the contact
  def remove(jid)
    return unless available?

    if contact = find(jid)
      contact.remove
      Log4r::Logger['app'].info "Remove contact #{jid}"

      changed
      notify_observers
    end
  end

  # Change contact groups
  #
  # *jid*:: JID of the contact
  # *groups*:: New groups of the contact, He can have more than one group
  def change_groups(jid, groups)
    return unless available?

    if contact = find(jid)
      contact.groups = groups
      contact.send

      Log4r::Logger['app'].info "Change group of #{jid} with #{groups.join(',')}"

      changed
      notify_observers
    end
  end

  # Return all groups
  #
  # *_return_* An array of string
  def groups
    return unless available?

    return @roster.groups
  end

  # Return all user contacts
  #
  # *_return_*:: An array of Jabber::RosterItem
  def contacts
    return unless available?

    return @roster.items.map {|jid,item| item}
  end

  # Return all groups for a contact
  #
  # *jid* :: JID of the contact
  # *_return_*:: An array of JID string
  def contact_groups(jid)
    return unless available?

    if contact = find(jid)
      return contact.groups
    else
      return Array.new
    end
  end

  # Find a contact in the user roster
  #
  # *jid* :: JID of the contact
  # *_return_*:: A Jabber::RosterItem
  def find(jid)
    return unless available?

    return @roster.find(jid).map {|jid,item| item}.first
  end

  # Check if the contact is online
  #
  # *jid* :: JID of the contact
  # *_return_*:: True if the contact is online
  def online?(jid)
    return unless available?

    if item = find(jid)
      return item.online?
    end

    false
  end

  # Set the stream of this controller
  #
  # *stream*:: A Jabber::Client to use
  def stream=(stream)
    @stream = stream

    if available?
      @roster = Jabber::Roster::Helper.new stream
      start_listening_presence
      start_listening_invitation
      @roster.wait_for_roster

      @stream.send Jabber::Presence.new

      changed
      notify_observers
    else
      @roster = nil
    end
  end

  # Test if this controller is ready
  #
  # *_return_*:: True if the controller is ready
  def available?
    (@stream)? true : false
  end

  private

  # Listener when contacts change their presence
  #
  # Only notify when the contact go online/offline, not when their jabber presence change
  def start_listening_presence
    @roster.add_presence_callback do |item, oldpres, pres|
      if presence_changed?(oldpres, pres)
        Log4r::Logger['app'].info "#{item.jid} is " + "#{(item.online?)?'online':'offline'}"

        changed
        notify_observers
      end
    end
  end

  # Listener when contacts want to add or remove you from his roster
  # Auto accept friend requests
  def start_listening_invitation
    # Callback to check when subscription state change
    @roster.add_subscription_callback do |item,pres|
      case pres.type
        when :subscribed then Log4r::Logger['app'].info "#{pres.from} subsribed"
        when :unsubscribed then Log4r::Logger['app'].info "#{pres.from} unsubscribed"
        when :unsubscribe then Log4r::Logger['app'].info "#{pres.from} unsubscribe"

        changed
        notify_observers
      end
    end

    # Callback to accept subscription
    @roster.add_subscription_request_callback do |item,pres|
      if pres.type = :subscribe
        @roster.accept_subscription pres.from
        Log4r::Logger['app'].info "Accept subscription from #{pres.from}"

        changed
        notify_observers
      end
    end
  end

  # Test if the contact go online/offline
  # Do not test when his Jabber presence changed
  #
  # *_return_* True if his presence changed
  def presence_changed?(oldpres, pres)
    if oldpres.nil? or oldpres.type == :unavailable or pres.type == :unavailable
      return true
    else
      return false
    end
  end
end
