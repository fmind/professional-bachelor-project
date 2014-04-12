require 'spec/spec_helper'

describe ServicesController, 'can ask if the server' do
  before :all do
    @services_controller = @app.services_controller
  end

  it 'has a proxy' do
    @services_controller.has_proxy?(Jabber::JID.new('im.apinc.org')).should be_true
    @services_controller.has_proxy?(Jabber::JID.new('fritalk.com')).should be_false
  end

  it 'has a publication/subscribe' do
    @services_controller.has_pubsub?(Jabber::JID.new('im.apinc.org')).should be_true
    @services_controller.has_pubsub?(Jabber::JID.new('fritalk.com')).should be_false
  end
end