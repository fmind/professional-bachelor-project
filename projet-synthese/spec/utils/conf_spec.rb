require 'spec/spec_helper'

describe Conf, 'after initialized' do
  before do
    @conf = Conf.instance
  end

  it 'has parameters if the file exists'  do
    @conf.init 'conf/default.yml'
    @conf.params.should_not be_nil
  end

  it 'raise an error if the file does not exist'  do
    lambda {@conf.init('conf/not_exising_file')}.should raise_error
  end

  after do
    @conf.init 'conf/dev.yml'
  end
end
