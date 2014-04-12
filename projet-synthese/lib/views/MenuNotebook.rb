# The main notebook of the application that includes transfers, roster, files and contact pages.
# This class permits to create those different pages and to switch between them.
class MenuNotebook < Wx::AuiNotebook

	attr_reader :files_page
	attr_reader :roster_page
	attr_reader :transfers_page
	attr_reader :parent

	# Call creation methods to initialize the notebook
	def initialize(parent = nil)
		@parent = parent
		super(parent, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::AUI_NB_CLOSE_ON_ACTIVE_TAB)

		@app = Wx::get_app()
		@contactPage = {}

		create_roster_page()
		create_files_page()
		create_transfers_page()

		set_selection(get_page_id(@roster_page))
	end

	# Display an error text within a modal popup
	# *msg*:: Error label that should be displayed
	def show_error(msg)
		@error_dialog = Wx::MessageDialog.new(self, msg, "Error !", Wx::ICON_ERROR)
		@error_dialog.show_modal()
	end

	# Create the page of a contact
	# *jid*:: Jid of the contact that must be shown
	def create_contact_page(jid)
		page_id = get_page_id(@contactPage[jid])
		# Create the page if it isn't created yet. Otherwise, just switch on it.
		if page_id == -1
			@contactPage[jid] = ContactPage.new(self, jid)
			@contactPage[jid].controller = @app.collection_controller
			@contactPage[jid].transfers_controller = @app.transfers_controller
			add_page(@contactPage[jid], jid)
			page_id = get_page_id(@contactPage[jid])
		end
		
		@contactPage[jid].refresh()
		set_selection(page_id)
	end

	# Create the roster page
	def create_roster_page()
		page_id = get_page_id(@roster_page)
		if page_id == -1
			@roster_page = RosterPage.new(self)
			@roster_page.controller = @app.roster_controller
			add_page(@roster_page, "My contacts")
			page_id = get_page_id(@roster_page)
		end

		set_selection(page_id)
	end

	# Create the collection files page
	def create_files_page()
		page_id = get_page_id(@files_page)
		if page_id == -1
			@files_page = MyFilesPage.new(self)
			@files_page.controller = @app.collection_controller
			add_page(@files_page, "My files")
			page_id = get_page_id(@files_page)
		end

		set_selection(page_id)
	end

	# Create the transfers page
	def create_transfers_page()
		page_id = get_page_id(@transfers_page)
		if page_id == -1
			@transfers_page = TransfersPage.new(self)
			@transfers_page.controller = @app.transfers_controller
			add_page(@transfers_page, "My transfers")
			page_id = get_page_id(@transfers_page)
		end

		set_selection(page_id)
	end

private

	# Get the tab id for a given page
	# *page*:: The notebook page for which we need the tab id
	def get_page_id(page)
		begin
			page_id = get_page_index(page)
		rescue Exception => e
			page_id = -1
		end

		return page_id
	end

end
