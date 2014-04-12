require 'Pr2Pr'

Spec::Runner.configure do |config|
  config.before :all do
    @app = Pr2Pr.new
    @app.debug = true
    @app.nox = true
    Conf.instance.init 'conf/dev.yml'
    params = Conf.instance.params

    @jid, @pass = Jabber::JID.new(params['account']['jid']), params['account']['password']
    @friend_user = params['account']['friend_user']
    @friend_pass = params['account']['friend_pass']
    @friends0_user =  params['account']['friends0_user']
    @new_user =  params['account']['new_user']
    @fake_user =  params['account']['fake_user']

    @app.accounts_controller.connect @jid, @pass
  end
end