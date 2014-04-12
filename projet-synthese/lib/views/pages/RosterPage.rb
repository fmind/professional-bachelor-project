# A page that display the roster. It enables to :
# * Add and delete contacts
# * Change contacts groups
# * Create groups
# * Open contact pages
class RosterPage < Wx::Panel

	include WidgetObserver

	# Call creation methods to initialize the page
	# *parent*:: The notebook
	def initialize(parent)
		@parent = parent
		super(@parent, -1)
		@style = Style.new()

		create_buttons()
		create_tree()

		link_events()

		display()
	end

	# Observation method called to refresh the roster
	def on_observation()
		@tree.delete_all_items()
		
		@tree_root = @tree.add_root("My contacts :")
		@tree.set_item_bold(@tree_root)

		@group_hash = Hash.new()
		ungrouped_contacts = Array.new()

		# Gather all contact groups of the user
		@controller.groups.each do |group|
			next unless group
			group_item = @tree.append_item(@tree_root, group)
			@group_hash[group] = group_item
		end

		@controller.contacts.each do |contact|
			# Get all groups of the contact
			groups = @controller.contact_groups(contact.jid)

			if groups.empty?
				ungrouped_contacts << contact
			else
				groups.each do |group|
					next unless group
					# Add the contact into the right branch
					contact_item = @tree.append_item(@group_hash[group], contact.jid.to_s)

					# Adapt the color and the icon if the contact is connected or not
					if @controller.online?(contact.jid.to_s)
						@tree.set_item_image(contact_item, @img_online)
						@tree.set_item_text_colour(contact_item, Wx::GREEN)
					else
						@tree.set_item_image(contact_item, @img_offline)
						@tree.set_item_text_colour(contact_item, Wx::RED)
					end
				end
			end
		end

		# Display groupless contacts into a separate branch
		if (!ungrouped_contacts.empty?)
			groupless = @tree.append_item(@tree_root, "Ungrouped contacts")
			@tree.set_item_text_colour(groupless, @style.gray)

			ungrouped_contacts.each do |contact|
				contact_item = @tree.append_item(groupless, contact.jid.to_s)
				@tree.set_item_text_colour(contact_item, @style.gray)
			end
		end

		@tree.refresh()
		@tree.expand_all()

		rescue Exception => e
			puts e.to_log
	end

	alias_method :refresh, :on_observation

private

	# Add a contact to the roster
	# *jid*:: The jid of the selected contact
	def add_contact(jid)
		@controller.add(jid)
	end

	# Delete a contact from the roster
	# *jid*:: The jid of the selected contact
	def del_contact(jid)
		@controller.remove(jid)
	end

	# Move a contact from a group to another one
	# *jid*:: The jid of the selected contact
	def move_contact(jid, group)
		@controller.change_groups(jid, [group])
	end

	# Show the page of a contact
	# *jid*:: The jid of the selected contact
	def show_contact_page(jid)
		@parent.create_contact_page(jid)
	end

	# Create a button above the tree to add a new contact
	def create_buttons()
		@buttons = Wx::BoxSizer.new(Wx::HORIZONTAL)

		@button_add_contact = Wx::Button.new(self, :label => "Add a new contact")
		@buttons.add(@button_add_contact, 0, Wx::ALL, 5)
	end

	# Create the roster as a tree control and initialize contact icons
	def create_tree()
		@tree = Wx::TreeCtrl.new(self)

		@tree_root = @tree.add_root("My contacts :")
		@tree.set_item_bold(@tree_root)

		# Load images in bitmap format
		img = Wx::Image.new($APP_ROOT+"/public/images/green_circle.png", Wx::BITMAP_TYPE_PNG)
		bitmap_online = Wx::Bitmap.from_image(img)
		img = Wx::Image.new($APP_ROOT+"/public/images/red_circle.png", Wx::BITMAP_TYPE_PNG)
		bitmap_offline = Wx::Bitmap.from_image(img)

		# Create an image list
		image_list = Wx::ImageList.new(16, 16)
		@img_online = image_list.add(bitmap_online)
		@img_offline = image_list.add(bitmap_offline)

		# Join the list to the created tree
		@tree.set_image_list(image_list)
	end
	
	# Link various events to frame controls
	def link_events()
		evt_button(@button_add_contact) { pop_add_contact() }
		evt_tree_item_right_click(@tree) { |event| show_roster_menu(event) }
	end

	# Create the main box and set it as the sizer of the page
	def display()
		@contact_box = Wx::BoxSizer.new(Wx::VERTICAL)

		@contact_box.add(@buttons, 0, Wx::ALL, 5)
		@contact_box.add(@tree, 1, Wx::ALL|Wx::EXPAND, 5)

		set_sizer(@contact_box)
	end

	# Create a menu after a right-click on a contact
	# *jid*:: The jid of the selected contact
	def create_contact_menu(jid)
		@menu_contacts = Wx::Menu.new()

		# Add a menu to show the contact's page
		id_show_contact_page = @menu_contacts.append(Wx::ID_ANY, "Show contact page", "Show contact")
		evt_menu(id_show_contact_page) { show_contact_page(jid) }

		# Add a menu to delete the contact
		id_del_contact = @menu_contacts.append(Wx::ID_ANY, "Delete "+jid, "Delete contact")
		evt_menu(id_del_contact) { del_contact(jid) }

		@menu_contacts.append_separator

		# Add a submenu to move a contact to another group
		@submenu_move = Wx::Menu.new()
		id_add_group = @submenu_move.append(Wx::ID_ANY, "New group...", "Create a new group")
		evt_menu(id_add_group) { pop_add_group(jid) }
		
		@controller.groups.each do |group|
			next unless group
			id_move_contact = @submenu_move.append(Wx::ID_ANY, group, "Move to")
			evt_menu(id_move_contact) { move_contact(jid, group) }
		end
		
		@menu_contacts.append_menu(-1, "Move to...", @submenu_move)
	end

	# Call the method to create the roster menu and show it
	def show_roster_menu(event)
		item_id = event.get_item

		if (@tree_root != item_id) and (!@group_hash.has_value?(item_id))
			jid = @tree.get_item_text(item_id)
			create_contact_menu(jid)
			popup_menu(@menu_contacts)
		end

		rescue Exception => e
			puts e.to_log
	end
	
	# Pop a dialog that ask a jid in order to add a new contact
	def pop_add_contact()
		@popup_addContact = Wx::TextEntryDialog.new(self, "Please enter a JID :", "Add a new contact", "")
		@popup_addContact.show_modal()
		jid = @popup_addContact.get_value()

		unless jid == nil
			add_contact(jid)
		end
	end

	# Pop a dialog that ask a group name in order to create a new group and to move the selected contact into it
	# *jid*:: The jid of the selected contact
	def pop_add_group(jid)
		@popup_add_group = Wx::TextEntryDialog.new(self, "Please choose a group name :", "Add a contact group", "")
		@popup_add_group.show_modal()
		group = @popup_add_group.get_value()

		if jid != nil and group != ""
			move_contact(jid, group)
		end
	end

end
