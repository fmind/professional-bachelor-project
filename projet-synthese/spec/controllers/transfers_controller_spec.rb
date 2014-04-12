require 'spec/spec_helper'
require 'fileutils'
include FileUtils

describe TransfersController, 'after initialized' do
  before :all do
    @transfers_controller = @app.transfers_controller
  end

  it 'has no transfers' do
    @transfers_controller.uploads.should be_empty
    @transfers_controller.downloads.should be_empty
  end
end