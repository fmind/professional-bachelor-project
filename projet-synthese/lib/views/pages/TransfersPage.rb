# A page that displays uploading and downloading files.
class TransfersPage < Wx::Panel

	include WidgetObserver

	# Call creation methods to initialize the page
	# *parent*:: The notebook
	def initialize(parent)
		@parent = parent
		super(@parent, -1)
		@style = Style.new()

		create_labels()
		create_buttons()
		create_download_list()
		create_upload_list()

		link_events()

		display()
	end

	# Observation method called to refresh download and upload lists
	def on_observation()
		@downloads = @controller.downloads
		in_download = false
		@uploads = @controller.uploads
		in_upload = false
		
		@download_list.delete_all_items()
		@upload_list.delete_all_items()

		# fill the download list
		i = 0
		@downloads.each do |file|
			@download_list.insert_item(i, file.destination.fname.to_s)
			@download_list.set_item(i, 1, file.from.to_s)
			@download_list.set_item(i, 3, file.state.to_s)

			if (file.state.to_s == "downloading")
				in_download = true
			end

			i+= 1
		end

		# fill the upload list
		i = 0
		@uploads.each do |file|
			@upload_list.insert_item(i, file.source.filename)
			@upload_list.set_item(i, 1, file.to.to_s)
			@upload_list.set_item(i, 2, file.state.to_s)

			if (file.state.to_s == "uploading")
				in_upload = true
			end

			i+= 1
		end

		# a small part of text that will be shown in the status bar
		activity = ""

		# start a new thread to show the % of downloading files if some of them are in activity
		if in_download
			@download_thread = Thread.new { loop { download_timer(); sleep(1) } }
			activity+= "Downloading..."
		else
			if (@download_thread != nil)
				@download_thread.kill()
				download_timer()
			end
		end

		# just show in the statusbar if the program is uploading files
		if in_upload
			if activity != ""
				activity+= " / Uploading..."
			else
				activity+= "Uploading..."
			end
		end

		# fill the status bar of the main frame
		@parent.parent.change_status(activity)

		rescue Exception => e
			puts e.message
	end

	alias_method :refresh, :on_observation

	# Create labels above download and upload lists
	def create_labels()
		@label_download = Wx::StaticText.new(self, :label => "Downloading files :")
		@label_download.set_font(@style.bold)

		@label_upload = Wx::StaticText.new(self, :label => "Uploading files :")
		@label_upload.set_font(@style.bold)
	end

	# Create a button to hide downloaded and uploaded files
	def create_buttons()
		@buttons = Wx::BoxSizer.new(Wx::HORIZONTAL)
		@button_clear = Wx::Button.new(self, :label => "Clear history")

		@buttons.add(@button_clear, 0, Wx::ALL, 0)
	end
	
	# Create the download list 
	def create_download_list()
		@download_list = Wx::ListCtrl.new(self, :style => Wx::LC_REPORT|Wx::LC_HRULES, :size => [-1, 100])
		@download_list.insert_column(0, "Name")
		@download_list.set_column_width(0, 160)
		@download_list.insert_column(1, "Source")
		@download_list.set_column_width(1, 250)
		@download_list.insert_column(2, "%")
		@download_list.set_column_width(2, 50)
		@download_list.insert_column(3, "State")
		@download_list.set_column_width(3, 100)
	end

	# Create the upload list
	def create_upload_list()
		@upload_list = Wx::ListCtrl.new(self, :style => Wx::LC_REPORT|Wx::LC_HRULES, :size => [-1, 100])
		@upload_list.insert_column(0, "Name")
		@upload_list.set_column_width(0, 160)
		@upload_list.insert_column(1, "Source")
		@upload_list.set_column_width(1, 300)
		@upload_list.insert_column(2, "State")
		@upload_list.set_column_width(2, 100)
	end
	
	# Create the main box and set it as the sizer of the page
	def display()
		@transfers_box = Wx::BoxSizer.new(Wx::VERTICAL)

		@transfers_box.add(@buttons, 0, Wx::ALL, 10)
		@transfers_box.add(@label_download, 0, Wx::ALL, 10)
		@transfers_box.add(@download_list, 0, Wx::ALL|Wx::EXPAND, 10)
		@transfers_box.add(@label_upload, 0, Wx::ALL, 10)
		@transfers_box.add(@upload_list, 0, Wx::ALL|Wx::EXPAND, 10)

		set_sizer(@transfers_box)
	end

	# Link various events to frame controls
	def link_events()
		evt_button(@button_clear) { clear_finished() }
	end
      
	# Hide all downloads and uploads that are finished
	def clear_finished
		@controller.clear_finished()
	end

	# Check and update downloading files progress
	def download_timer()
		i = 0
		@downloads.each do |file|
			path = [$APP_ROOT, "downloads", file.destination.fname.to_s].join('/')
			if (File.exist?(path) and file.state.to_s == "downloading")
				current_size = File.size(path)
				total_size = file.destination.size
				percent = ((current_size.to_f/total_size.to_f)*(100)).to_i
				
				@download_list.set_item(i, 2, percent.to_s)
			end
			i+= 1
		end
	end
end
