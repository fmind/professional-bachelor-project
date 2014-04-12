# Contains namespace of a file transfer IQ query
class QueryFileTransfer < Jabber::IqQuery
  NAMESPACE = 'jabber:iq:filetransfer'

  name_xmlns 'query', NAMESPACE
  force_xmlns true
end

# IQ to request a contact file upload
class IqFileTransfer < Jabber::Iq

  # *file* filename String to upload
  # *to* JID of contact to request
  def initialize(file, to)
    to.resource = 'Pr2Pr'
    super(:get, to)

    add QueryFileTransfer.new
    self.file = file
  end

  # Set the file element
  #
  # *file* filename String to upload
  def file=(file)
    replace_element_text('file', file)
  end

  # Get the file element
  #
  # *_return_* filename string to upload
  def file
    first_element_text 'file'
  end
end