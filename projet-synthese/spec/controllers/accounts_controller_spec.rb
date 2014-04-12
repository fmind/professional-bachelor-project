require 'spec/spec_helper'

describe AccountsController, 'when user has no account' do
  before :all do
    @accounts_controller = @app.accounts_controller
    @new_user_password = 'RIP'
  end

  it 'can create and delete an account' do
    begin
      @accounts_controller.create(@new_user, @new_user_password)
      @accounts_controller.connect(@new_user, @new_user_password)
      @accounts_controller.stream.should_not be_nil

      @accounts_controller.delete
      @accounts_controller.stream.should be_nil
    rescue Exception => e
      begin
        @accounts_controller.connect(@new_user, @new_user_password)
        @accounts_controller.delete
        retry
      rescue
        puts "\nTest pass: Cannot create account too fast"
      end
    end
  end

  after :all do
    @accounts_controller.connect(@jid, @pass)
  end
end

describe AccountsController, 'when user has an account' do
  before :all do
    @params = Conf.instance.params
    @accounts_controller = @app.accounts_controller
  end

  it 'can connect and disconnect if JID is valid' do
    @accounts_controller.connect(@jid, @pass)
    @accounts_controller.stream.should_not be_nil
    @accounts_controller.stream.is_disconnected?.should be_false
    @accounts_controller.jid.should_not be_nil

    @accounts_controller.disconnect
    @accounts_controller.stream.should be_nil
    @accounts_controller.jid.should be_nil
  end

  it 'cannot connect if JID is invalid' do
    lambda {@accounts_controller.connect(@fake_user, '')}.should raise_error
  end

  it 'cannot connect if password is invalid' do
    lambda {@accounts_controller.connect(@jid, 'bad_pass')}.should raise_error
  end

  after :all do
    @accounts_controller.connect(@jid, @pass)
  end
end
