--[[--
 @package   Contacts
 @filename  src/app.lua
 @version   3.0
 @autor     Diaz Urbaneja Victor Diego Alejandro <sodomon2@gmail.com>
 @date      04.03.2021 22:57:07 -04
]]

function notification(title,msg)
	Notify.init("init")
	message = Notify.Notification.new
	msg = message(title,msg)
	msg:show()
end

function ui.menu_about:on_clicked()
	ui.about_window:run()
	ui.about_window:hide()
end

function ui.menu_quit_login:on_clicked()
	ui.stack:set_visible_child_name('login')
	ui.entry_username.text = ""
    ui.entry_password.text = ""
end

function ui.main_window:on_destroy()
	Gtk.main_quit()
end

function ui.btn_add:on_clicked()
	insert_data()
end

function ui.btn_login:on_clicked()
	insert_user()
	aceptar()
end

function ui.entry_password:on_key_release_event(env)
	if ( env.keyval  == Gdk.KEY_Return ) then
	  aceptar()
	end
end

function ui.btn_cancel:on_clicked()
    ui.contacts_expander:set_expanded(false)
	ui.entry_name.text = ""
    ui.entry_number.text = ""
    ui.entry_city.text = ""
end

