# Represent a file transfer between 2 contacts
#
# a transfer is observable, it notify when state change
class Transfer
  include Observable

  attr_reader :state

  # Change the state of the transfer
  # also notify observers
  #
  # *state* the state Symbol of the transfer (ex: finish, downloading...)
  def state=(state)
    @state = state
    changed
    notify_observers
  end
end