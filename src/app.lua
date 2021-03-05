--[[--
 @package   Contacts
 @filename  src/app.lua
 @version   3.0
 @autor     Diaz Urbaneja Victor Diego Alejandro <sodomon2@gmail.com>
 @date      04.03.2021 22:57:07 -04
]]

function ui.btn_user_ok:on_clicked()
    insert_user()
end

function ui.btn_user:on_clicked()
    ui.window_user:show_all()
    ui.dialog_login:hide()
end

function ui.btn_user_cancel:on_clicked()
    ui.dialog_login:show_all()
    ui.window_user:hide()
end

function ui.btn_cancel:on_clicked()
    Gtk.main_quit()
end

function ui.menu_about:on_clicked()
    ui.about_window:run()
    ui.about_window:hide()
end

function ui.menu_quit_login:on_clicked()
    ui.main_window:hide()
    ui.dialog_login:show_all()
end

function ui.main_window:on_destroy()
    Gtk.main_quit()
end

function ui.btn_registrar:on_clicked()
	insert_data()
end

function ui.btn_ok:on_clicked()
    aceptar()
end

function ui.entry_password:on_key_release_event(env)
    if ( env.keyval  == Gdk.KEY_Return ) then
      aceptar()
    end
end

