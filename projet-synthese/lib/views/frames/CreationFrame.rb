# The creation frame is used to create a new account.
class CreationFrame < Wx::Frame

	# Call creation methods to initialize the frame
	def initialize(parent)
		super(parent, :title => "Pr2pr - Account creation", :size => [600, 300])
		@parent = parent
		@app = Wx::get_app

		set_style()

		create_error_box()
		create_title()
		create_form()
		create_buttons()

		link_events()

		display()
	end

	# Initialize the frame style
	def set_style()
		@style = Style.new()

		@form_size = Wx::Size.new(150, -1)

		set_min_size(Wx::Size.new(400, 300))
		set_max_size(Wx::Size.new(600, 300))

		set_background_colour(Wx::WHITE)
	end

	# Create a space to display errors
	def create_error_box()
		@error_box = Wx::BoxSizer.new(Wx::VERTICAL)

		@error = Wx::StaticText.new(self, :label => "", :style => Wx::ALIGN_CENTER)
		@error.set_font(@style.bold)
		@error.set_foreground_colour(Wx::RED)

		@error_box.add(@error, 1)
		@error_box.add_spacer(0)
	end

	# Create the frame's title
	def create_title()
		@title = Wx::BoxSizer.new(Wx::VERTICAL)

		@label_title = Wx::StaticText.new(self, :label => "Create your jabber account")
		@label_title.set_font(@style.h2)

		@title.add(0, 20, 0, Wx::EXPAND)
		@title.add(@label_title, 1, Wx::ALL, 10)
	end

	# Create the account creation form
	def create_form()
		@form = Wx::GridSizer.new(3, 2, 5, 0)

		# First row : JID
		@label_name = Wx::StaticText.new(self, :label => "Account name : ")
		@form.add(@label_name, 0, Wx::ALIGN_CENTER_VERTICAL|Wx::ALIGN_RIGHT)

		@name = Wx::TextCtrl.new(self, :size => @form_size)
		@form.add(@name, 0, Wx::ALIGN_CENTER_VERTICAL)

		# Second row : password
		@label_password = Wx::StaticText.new(self, :label => "Password : ")
		@form.add(@label_password, 0, Wx::ALIGN_CENTER_VERTICAL|Wx::ALIGN_RIGHT)

		@password = Wx::TextCtrl.new(self, :size => @form_size, :style => Wx::TE_PASSWORD)
		@form.add(@password, 0, Wx::ALL)

		# Third row : retype password
		@label_password2 = Wx::StaticText.new(self, :label => "Retype password : ")
		@form.add(@label_password2, 0, Wx::ALIGN_CENTER_VERTICAL|Wx::ALIGN_RIGHT)

		@password2 = Wx::TextCtrl.new(self, :size => @form_size, :style => Wx::TE_PASSWORD)
		@form.add(@password2, 0, Wx::ALL)

		# Fourth row : server
		@label_server = Wx::StaticText.new(self, :label => "Server : ")
		@form.add(@label_server, 0, Wx::ALIGN_CENTER_VERTICAL|Wx::ALIGN_RIGHT)

		@server = Wx::TextCtrl.new(self, :size => @form_size)
		@form.add(@server)

		# Fifth empty row
		@form.add_spacer(0)
		@form.add_spacer(0)
	end

	# Create buttons to validate or cancel the creation
	def create_buttons
		@buttons = Wx::GridSizer.new(1, 2, 0, 5)

		@button_cancel = Wx::Button.new(self, :label => "Cancel")
		@buttons.add(@button_cancel, 0, Wx::ALIGN_RIGHT|Wx::RIGHT)

		@button_create = Wx::Button.new(self, :label => "Create")
		@buttons.add(@button_create, 0, Wx::ALIGN_LEFT|Wx::LEFT)
	end

	# Link various events to frame controls
	def link_events()
		evt_button(@button_create) { create_account() }
		evt_button(@button_cancel) { destroy() }
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

	# Create the account by using informations in the frame
	def create_account()
		# Get all informations
		name = @name.get_value().to_s
		password = @password.get_value().to_s
		password2 = @password2.get_value().to_s
		server = @server.get_value().to_s

		if password != password2
			@error.set_label("Passwords are different")
		else
			begin
				# If passwords are not different, create the account and redirect the user to the connection frame
				@app.accounts_controller.create(name+"@"+server, password)
				@parent.set_default_jid(name+"@"+server)
				@parent.empty_password()
				destroy()
			rescue Exception => e
				@error.set_label(e.message)
			end
		end
	end
end
