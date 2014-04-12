# Ruby mixin for observer widget classes :
#
# - Helper to setup widget observer
# - Use a proxy observer because Wx widgets already have a update method
module WidgetObserver
  attr_writer :controller
  attr_reader :observer

  # Set the widget controller
  # *A widget can only observe one controller*
  def controller=(controller)
    @observer = ProxyObserver.new(self, :on_observation)
    @controller = controller
    @controller.add_observer @observer

    evt_window_destroy do |event|
      @controller.delete_observer(@observer)
      event.skip
    end
  end
end