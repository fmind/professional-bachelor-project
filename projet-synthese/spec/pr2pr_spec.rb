require 'spec/spec_helper'

describe Pr2Pr, 'after initialized' do
  it 'has a configuration' do
    conf = Conf.instance
    conf.params.should_not be_nil
  end

  it 'has a logger' do
    Log4r::Logger['app'].should_not be_nil
  end

  it 'must run without user interface and in debug mode' do
    @app.debug.should be_true
    @app.nox.should be_true
  end
end