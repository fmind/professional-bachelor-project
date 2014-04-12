require 'spec/spec_helper'

describe CollectionController, 'when has no files' do
  before :all do
    @collection_controller = @app.collection_controller
  end

  it 'can add and delete files if the file exists' do
    @collection_controller.add __FILE__
    @collection_controller.filepaths.should include(File.expand_path(__FILE__))
    @collection_controller.filenames.should include(File.basename(__FILE__))

    @collection_controller.delete __FILE__
    @collection_controller.filepaths.should_not include(File.expand_path(__FILE__))
    @collection_controller.filenames.should_not include(__FILE__)
  end

  it 'cannot add files if the file does not exist' do
    lambda {@collection_controller.add '/fake/file'}.should raise_error
  end

  it 'cannot delete files if they are not in collection' do
    lambda {@collection_controller.delete '/fake/file'}.should raise_error
  end
end

describe CollectionController, 'when has files' do
  before :all do
    @collection_controller = @app.collection_controller
    @collection_controller.add 'README.rdoc'
    @collection_controller.add 'lib/pr2pr.rb'
  end

  it 'can get the fullpath on a file based on its ID' do
    @collection_controller.path('pr2pr.rb').should == File.expand_path('lib/pr2pr.rb')
    @collection_controller.path('README.rdoc').should == File.expand_path('README.rdoc')
  end

  after :all do
    @collection_controller.delete 'README.rdoc'
    @collection_controller.delete 'lib/pr2pr.rb'
  end
end