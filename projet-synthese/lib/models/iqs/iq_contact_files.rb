# Contains namespace of a contact file IQ query
class QueryContactFiles < Jabber::IqQuery
  NAMESPACE = 'jabber:iq:contact-files'

  name_xmlns 'query', NAMESPACE
  force_xmlns true
end

# IQ to request contact files
class IqContactFiles < Jabber::Iq

  # *to* JID of the contact
  def initialize(to)
    to = Jabber::JID.new to unless to.class == Jabber::JID
    to.resource = 'Pr2Pr'
    super(:get, to)

    add QueryContactFiles.new
  end
end

# IQ result
# return all contact files
class IqResContactFiles < Jabber::Iq

  # *files* An array of filename String
  # *iq* The IqResContactFiles source
  def initialize(files, iq)
    to = Jabber::JID.new iq.from
    to.resource = 'Pr2Pr'
    super(:result, to)
		self.id = iq.id

    add QueryContactFiles.new

    self.files = files
  end

  # Set IQ file elements
  #
  # *files* An array of filename String
  def files=(files)
    files.each do |file|
      element = REXML::Element.new 'file'
			element.text = file
			add_element element
    end
  end
end
