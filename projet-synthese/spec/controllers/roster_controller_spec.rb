require 'spec/spec_helper'

describe RosterController, 'when user has no contact' do
  before :all do
    @app.accounts_controller.connect @friends0_user, 'GoingHome'
    @roster_controller = @app.roster_controller
    @roster_controller.contacts.each {|contact| @roster_controller.remove(contact)}
  end

  it 'can add and get its contact' do
    @roster_controller.add @friend_user

    contacts = @roster_controller.contacts.map {|contact| contact.jid}
    contacts.should include(@friend_user)
  end

  after :all do
    @app.accounts_controller.connect(@jid, @pass)
  end
end

describe RosterController, 'when user has contact' do
  before :all do
    @app.accounts_controller.connect @friends0_user, 'GoingHome'
    @roster_controller = @app.roster_controller
    @roster_controller.contacts.each {|contact| contact.remove}
    @roster_controller.add @friend_user
  end

  it 'can find contacts by his JID' do
    @roster_controller.find(@friend_user).jid.should == @friend_user
    @roster_controller.find(@fake_user).should be_nil
  end

  it 'can remove a contacts' do
    @roster_controller.remove @friend_user
    @roster_controller.find(@friend_user).should be_nil
    @roster_controller.add @friend_user
  end

  it 'can change contact groups and get all groups' do
    @roster_controller.contact_groups(@friend_user).should be_empty
    @roster_controller.change_groups(@friend_user, ['south park', 'friends'])
    @roster_controller.contact_groups(@friend_user).should include('south park', 'friends')

    @roster_controller.groups.should include('south park', 'friends')
  end

  after :all do
    @app.accounts_controller.connect(@jid, @pass)
  end
end

describe RosterController, 'when contacts presence change' do
  before :all do
    @roster_controller = @app.roster_controller
  end

  it 'can check when contact are offline' do
    @roster_controller.online?(@roster_controller.find(@friend_user)).should be_false
  end
end