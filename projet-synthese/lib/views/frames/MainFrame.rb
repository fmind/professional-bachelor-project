# The main frame of Pr2pr. It permits to use all Pr2pr functionalities when the user is connected.
class MainFrame < Wx::Frame

	# Call creation methods to initialize the frame
	def initialize()
		super(nil, :title => 'Pr2pr', :size => [600,600])
		@app = Wx::get_app

		set_style()

		create_menubar()
		create_account_box()
		create_notebook_box()
		create_statusbar()

		link_events()

		display()
	end

	# Initialize the frame style
	def set_style()
		@style = Style.new()

		set_min_size(Wx::Size.new(400, 600))
		set_max_size(Wx::Size.new(800, 600))

		set_background_colour(Wx::WHITE)
	end
	
	# Create the menubar of the program
	def create_menubar()
		@menubar = Wx::MenuBar.new

		@menubar_account = Wx::Menu.new
		@id_disconnect = @menubar_account.append(Wx::ID_ANY, "Disconnect\tCtrl-D", "Disconnect")
		@menubar_account.append_separator()
		@menubar_account.append(Wx::ID_EXIT, "Exit\tCtrl-Q", "Close the program")
		@menubar.append(@menubar_account, "&Account")

		@menubar_view = Wx::Menu.new
		@id_create_roster_page = @menubar_view.append(Wx::ID_ANY, "Display the roster\tCtrl-R", "Display the roster page")
		@id_create_files_page = @menubar_view.append(Wx::ID_ANY, "Display files\tCtrl-F", "Display the files page")
		@id_create_transfers_page = @menubar_view.append(Wx::ID_ANY, "Display transfers\tCtrl-T", "Display the transfers page")
		@menubar.append(@menubar_view, "&View")

		@menubar_help = Wx::Menu.new
		@menubar_help.append(Wx::ID_ABOUT, "About\tF1", "About")
		@menubar.append(@menubar_help, "&Help")

		self.menu_bar = @menubar
	end

	# Create the account block
	def create_account_box()
		# Title
		@account_title = Wx::BoxSizer.new(Wx::VERTICAL)

		@label_account = Wx::StaticText.new(self, :label => "My account")
		@label_account.set_font(@style.h2)
		@label_account.set_foreground_colour(Wx::BLUE)

		@account_title.add(@label_account, 0, Wx::ALL, 10)

		@account_box = Wx::GridSizer.new(2, 2, 0, 0)
		# First row : account
		@label_jid = Wx::StaticText.new(self, :label => "Connected as : ")
		@jid = Wx::StaticText.new(self, :label => @app.accounts_controller.jid.to_s)
		@jid.set_font(@style.bold)

		@account_box.add(@label_jid, 0, Wx::ALL|Wx::ALIGN_CENTER_VERTICAL, 10)
		@account_box.add(@jid, 0, Wx::ALL, 10)

		# Second row : status (unused)
		@label_status = Wx::StaticText.new(self, :label => "Status : ")
		@status = Wx::StaticText.new(self, :label => "Available")
		@status.set_foreground_colour(Wx::GREEN)

		@account_box.add(@label_status, 0, Wx::ALL|Wx::ALIGN_CENTER_VERTICAL, 10)
		@account_box.add(@status, 0, Wx::ALL, 10)
	end

	# Create the notebook
	def create_notebook_box()
		# Title
		@notebook_title = Wx::BoxSizer.new(Wx::VERTICAL)

		@label_notebook = Wx::StaticText.new(self, :label => "Menu")
		@label_notebook.set_font(@style.h2)
		@label_notebook.set_foreground_colour(Wx::BLUE)

		@notebook_title.add(@label_notebook, 0, Wx::ALL, 10)

		# The notebook by itself
		@notebook = MenuNotebook.new(self)
	end

	# Create the bottom bar that is used to display upload/download activities
	def create_statusbar()
		@statusbar = Wx::StatusBar.new(self, -1)
		set_status_bar(@statusbar)
	end

	# Link various events to frame controls
	def link_events()
		evt_menu(Wx::ID_ABOUT) { pop_about() }
		evt_menu(@id_disconnect) { disconnect() }
		evt_menu(Wx::ID_EXIT, :destroy)

		evt_menu(@id_create_roster_page) do
			@notebook.create_roster_page()
			@notebook.roster_page.refresh()
		end

		evt_menu(@id_create_files_page) do
			@notebook.create_files_page()
			@notebook.files_page.refresh()
		end

		evt_menu(@id_create_transfers_page) do
			@notebook.create_transfers_page()
			@notebook.transfers_page.refresh()
		end

		@timer = Wx::Timer.new(self)
		evt_timer(@timer.id) { Thread.pass }
		@timer.start(2)
	end

	# Create the main box and set it as the sizer of the frame
	def display()
		centre()

		@box = Wx::BoxSizer.new(Wx::VERTICAL)
		@box.add(@account_title, 0, Wx::EXPAND)
		@box.add(@account_box, 0, Wx::EXPAND)
		@box.add(@notebook_title, 0, Wx::EXPAND)
		@box.add(@notebook, 1, Wx::EXPAND)
		set_sizer(@box)
	end

	# Show the "About" popup
	def pop_about()
		@popup_about = Wx::AboutDialogInfo.new()
		@popup_about.set_name('Pr2pr')
		@popup_about.set_version('1.0.0')
		@popup_about.add_developer('Médéric Hurier')
		@popup_about.add_developer('Sylvain Dubus')
		@popup_about.set_web_site('http://freaxmind.hd.free.fr/projects/projects/pr2pr')

		Wx::about_box(@popup_about)
	end

	# Disconnect the user
	def disconnect()
		@app.accounts_controller.disconnect()
	end

	# Modify the statusbar text
	# *activity*:: New text for the statusbar
	def change_status(activity)
		@statusbar.set_status_text(activity, 0)
	end
end
