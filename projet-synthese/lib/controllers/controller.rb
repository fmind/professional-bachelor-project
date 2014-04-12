# Parent class for all application controller
# Controllers are observable and must notify when they changed
class Controller
  include Observable

  # Initialize the controller
  #
  # *app*:: Application of the controller to retrieve other controllers
  def initialize(app)
    @app = app
  end
end