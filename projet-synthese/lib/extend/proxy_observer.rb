# Proxy class for update method
# Use on classes which have already an update method
class ProxyObserver

  # Initialize the proxy observer
  #
  # *object*:: the observable object
  # *method*:: observable method to call
  def initialize(observable, method)
    @observable = observable
    @method = method
  end

  # Proxy method
  def update
    @observable.send @method
  end
end