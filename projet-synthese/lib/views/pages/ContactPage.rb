# A page that display shared files of a contact.
# It permits to download them.
class ContactPage < Wx::Panel

	include WidgetObserver

	attr_writer :transfers_controller

	# Call creation methods to initialize the page
	# *parent*:: The notebook
	# *jid*:: The jid of the selected contact
	def initialize(parent, jid)
		@parent = parent
		@jid = jid
		super(@parent, -1)
		@style = Style.new()

		create_buttons()
		create_title()
		create_error_label()
		create_file_list()

		link_events()

		display()
	end

	# Observation method called to refresh the files list
	def on_observation()
		@file_list.delete_all_items()

		files = @controller.contact_files(@jid)
		i = 0

		unless files.empty?
			files.each do |file|
				@file_list.insert_item(i, file)
				i = i + 1
			end
		else
			@error.set_label("No shared files")
		end
		
		rescue Exception => e
			if e.error.code == 503
				error_message = "Your contact doesn't use Pr2Pr application"
			else
				error_message = e.message
			end
			@parent.show_error(error_message)
			@error.set_label(error_message)
	end

	alias_method :refresh, :on_observation

	# Download all files that are selected in the list
	def request_files()
		selected_files = []
		# Gather selected files and keep them separately in an array
		@file_list.get_selections.each do |row|
			selected_files << @file_list.get_item(row, 0).get_text()
		end
		
		# Deleted selected files
		selected_files.each do |file|
			@transfers_controller.request(file, @jid)
		end
	end

	# Create a title that contains the contact jid above his shared files
	def create_title()
		@title = Wx::StaticText.new(self, :label => @jid.to_s.capitalize+"'s files :")
		@title.set_font(@style.bold)
	end

	# Keep free space to display errors
	def create_error_label()
		@error = Wx::StaticText.new(self, :label => "")
		@error.set_font(@style.bold)
		@error.set_foreground_colour(Wx::RED)
	end

	# Create the file list
	def create_file_list()
		@file_list = Wx::ListCtrl.new(self, :style => Wx::LC_REPORT|Wx::LC_HRULES, :size => [-1, 250])
		@file_list.insert_column(0, "Name")
		@file_list.set_column_width(0, 300)
	end

	# Create a button that refresh manually the file list
	def create_buttons()
		@buttons = Wx::BoxSizer.new(Wx::HORIZONTAL)
		@button_refresh = Wx::Button.new(self, :label => "Refresh")

		@buttons.add(@button_refresh, 0, Wx::ALL, 0)
	end
	
	# Create the main box and set it as the sizer of the page
	def display()
		@contact_box = Wx::BoxSizer.new(Wx::VERTICAL)

		@contact_box.add(@buttons, 0, Wx::ALL, 10)
		@contact_box.add(@title, 0, Wx::ALL, 10)
		@contact_box.add(@error, 0, Wx::LEFT|Wx::RIGHT, 10)
		@contact_box.add(@file_list, 0, Wx::ALL|Wx::EXPAND, 10)

		set_sizer(@contact_box)
	end
	
	# Link various events to frame controls
	def link_events()
		evt_list_item_right_click(@file_list) { show_file_menu() }
		evt_button(@button_refresh) { refresh() }
		
		rescue Exception => e
			puts e.message
	end
	
	# Show a menu after a right-click on a file that permit to download all selected files
	def show_file_menu()
		@file_menu = Wx::Menu.new()
		id_download = @file_menu.append(Wx::ID_ANY, "Download", "Download selected files")

		evt_menu(id_download) { request_files() }
		
		popup_menu(@file_menu)
	end
end
