# A page that display all files that the user previously added to his shared collection files.
# It just permits to add or delete files.
class MyFilesPage < Wx::Panel

	include WidgetObserver

	# Call creation methods to initialize the page
	# *parent*:: The notebook
	def initialize(parent)
		@parent = parent
		super(@parent, -1)
		@style = Style.new()

		create_title()
		create_buttons()
		create_file_list()

		link_events()
		display()
	end

	# Observation method called to refresh the files list
	def on_observation()
		@files = @controller.filepaths()
		@file_list.delete_all_items()

		return unless @files

		i = 0
		size_units = ["o", "Ko", "Mo", "Go", "To", "Po"]
		
		@files.each do |file_path|
			# Add the file name
			cut_file = file_path.split('/')
			@file_list.insert_item(i, cut_file.last())

			if (File.exist?(file_path))
				# Calculate and add the size
				size = File.size(file_path)
				unit = 0
				
				while (size > 1024)
					unit+= 1
					size/= 1024
				end
				
				@file_list.set_item(i, 1, size.to_s+" "+size_units[unit])
				
				# Add the directory where the file is located
				@file_list.set_item(i, 2, File.dirname(file_path))
			else
				@file_list.set_item(i, 2, "file not found !")
			end
			i+= 1
		end
		
		rescue Exception => e
			puts e.message
	end

	alias_method :refresh, :on_observation

	# Create a button to add any files from the disk
	def create_buttons()
		@buttons = Wx::BoxSizer.new(Wx::HORIZONTAL)
		@button_add_file = Wx::Button.new(self, :label => "Add a new file")

		@buttons.add(@button_add_file, 0, Wx::ALL, 5)
	end
	
	# Create a title above the file list
	def create_title()
		@label_file_list = Wx::StaticText.new(self, :label => "My shared files :")
		@label_file_list.set_font(@style.bold)
	end

	# Create the list that contain all shared files with their sizes and locations
	def create_file_list()
		@file_list = Wx::ListCtrl.new(self, :style => Wx::LC_REPORT|Wx::LC_HRULES, :size => [-1, 200])
		@file_list.insert_column(0, "Name")
		@file_list.set_column_width(0, 180)
		@file_list.insert_column(1, "Size")
		@file_list.set_column_width(1, 80)
		@file_list.insert_column(2, "Directory")
		@file_list.set_column_width(2, 300)

		rescue Exception => e
			puts e.message
	end

	# Create the main box and set it as the sizer of the page
	def display()
		@files_box = Wx::BoxSizer.new(Wx::VERTICAL)

		@files_box.add(@buttons, 0, Wx::ALL, 5)
		@files_box.add(@label_file_list, 0, Wx::ALL, 10)
		@files_box.add(@file_list, 1, Wx::ALL|Wx::EXPAND, 10)

		set_sizer(@files_box)
	end

	# Link various events to frame controls
	def link_events()
		evt_button(@button_add_file) { pop_add_file() }
		evt_list_item_right_click(@file_list) { show_file_menu() }
	end

	# Pop a dialog that ask a file to add to the collection
	def pop_add_file()
		@file_dialog = Wx::FileDialog.new(self, :wildcard => "*")
		
		if @file_dialog.show_modal == Wx::ID_OK
			@controller.add(@file_dialog.get_path())
		end

		rescue Exception => e
			@parent.show_error(e.message)
	end

	# Remove all files that are selected in the list
	def remove_files()
		selected_files = []
		# Gather selected files and keep them separately in an array
		@file_list.get_selections.each do |row|
			selected_files << @file_list.get_item(row, 0).get_text()
		end
		
		# Deleted selected files
		selected_files.each do |file|
			@controller.delete(file)
		end
	end

	# Show a menu after a right-click on a file that permit to remove all selected files
	def show_file_menu()
		@file_menu = Wx::Menu.new()
		id_remove = @file_menu.append(Wx::ID_ANY, "Remove from collection", "Delete selected files from the database")

		evt_menu(id_remove) { remove_files() }
		
		popup_menu(@file_menu)
	end
end
