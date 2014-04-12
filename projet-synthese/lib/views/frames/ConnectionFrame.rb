# The first frame that appear to the user. It permits either to create a new account or to connect.
class ConnectionFrame < Wx::Frame

	# Call creation methods to initialize the frame
	def initialize()
		super(nil, :title => "Pr2pr - Connection", :size => [750,250])
		@app = Wx::get_app

		set_style()

		create_title()
		create_error_box()
		create_form()
		create_buttons()

		link_events()

		display()
	end

	# Initialize the frame style
	def set_style()
		@style = Style.new()

		@form_size = Wx::Size.new(200, -1)

		set_min_size(Wx::Size.new(600, 250))
		set_max_size(Wx::Size.new(900, 250))

		set_background_colour(Wx::WHITE)
	end

	# Create a big centered title in the frame
	def create_title()
		@title = Wx::BoxSizer.new(Wx::VERTICAL)

		@label_title = Wx::StaticText.new(self, -1, "Pr2pr : share with your friends")
		@label_title.set_font(@style.h1)

		@title.add(0, 20, 0, Wx::EXPAND)
		@title.add(@label_title, 1, Wx::ALIGN_CENTER)
		@title.add(0, 20, 0, Wx::EXPAND)
	end

	# Create a space to display errors
	def create_error_box()
		@error_box = Wx::BoxSizer.new(Wx::VERTICAL)

		@error = Wx::StaticText.new(self, :label => '', :style => Wx::ALIGN_CENTER)
		@error.set_font(@style.bold)
		@error.set_foreground_colour(Wx::RED)

		@error_box.add(@error, 1)
		@error_box.add(0, 10, 0, Wx::EXPAND)
	end

	# Create the connection form
	def create_form()
		@form = Wx::GridSizer.new(4, 2, 5, 0)

		# First row : account
		@label_jid = Wx::StaticText.new(self, :label => "Jabber account : ")
		@form.add(@label_jid, 0, Wx::ALIGN_CENTER_VERTICAL|Wx::ALIGN_RIGHT)

		@jid = Wx::TextCtrl.new(self, :value => Conf.instance.params['account']['jid'], :size => @form_size)
		@form.add(@jid)

		# Second row : a link about Jabber
		@link_jabber = Wx::HyperlinkCtrl.new(self, :label => "What is Jabber ?", :url => "http://wiki.jabberfr.org/Accueil", :size => @form_size)
		@form.add_spacer(0)
		@form.add(@link_jabber)

		# Third row : password
		@label_password = Wx::StaticText.new(self, :label => "Password : ")
		@form.add(@label_password, 0, Wx::ALIGN_CENTER_VERTICAL|Wx::ALIGN_RIGHT)

		@password = Wx::TextCtrl.new(self, :value => Conf.instance.params['account']['password'], :size => @form_size, :style => Wx::TE_PASSWORD)
		@form.add(@password)

		# Fourth empty row
		@form.add_spacer(0)
		@form.add_spacer(0)
	end


	# Create two buttons to create an account or to connect to the application
	def create_buttons()
		@buttons = Wx::GridSizer.new(1, 2, 0, 5)

		@button_create_account = Wx::Button.new(self, :label => "Create an account")
		@buttons.add(@button_create_account, 0, Wx::ALIGN_RIGHT|Wx::RIGHT)

		@button_join = Wx::Button.new(self, :label => "Connect")
		@buttons.add(@button_join, 0, Wx::ALIGN_LEFT|Wx::LEFT)
	end

	# Link various events to frame controls
	def link_events()
		evt_button(@button_create_account) { create_account() }
		evt_button(@button_join) { join(@jid.get_value(), @password.get_value()) }
	end

	# Create the main box and set it as the sizer of the frame
	def display()
		centre()

		@box = Wx::BoxSizer.new(Wx::VERTICAL)
		@box.add(@title, 0, Wx::EXPAND)
		@box.add(@error_box, 0, Wx::ALIGN_CENTER|Wx::ALL)
		@box.add(@form, 0, Wx::EXPAND)
		@box.add(@buttons, 0, Wx::EXPAND)

		set_sizer(@box)
	end

	# Set the new jid as the default jid after the creation of a new account
	# *default_jid*:: Default jid to display
	def set_default_jid(default_jid)
		@jid.set_value(default_jid) unless default_jid == nil
	end
	
	def empty_password()
		@password.change_value("")
	end

	# Display the creation frame
	def create_account()
		creation_frame = CreationFrame.new(self)
		creation_frame.show()
	end

	# Connect the user to Pr2pr, using given jid and password in the form
	# *jid*:: Jid insered in the form
	# *password*:: Password insered in the form
	def join(jid, password)
		begin
			@app.accounts_controller.connect(jid, password)
		rescue Exception => e
			@error.set_label(e.message)
			@password.change_value("")
		end
	end

end
