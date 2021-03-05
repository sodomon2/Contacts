--[[--
 @package   Contacts
 @filename  src/tray.lua
 @version   3.0
 @autor     Diaz Urbaneja Victor Diego Alejandro <sodomon2@gmail.com>
 @date      04.03.2021 22:59:13 -04
]]

function trayicon()
	visible = not visible
    if ui.main_window.is_active then
        ui.dialog_login:hide()
    else
        if visible then
            ui.dialog_login:show_all()
        else
            ui.dialog_login:hide()
        end
    end
end

function ui.agenda:on_activate()
	trayicon()
end

function create_menu(event_button, event_time)
    menu = Gtk.Menu {
        Gtk.ImageMenuItem {
            label = "Quit",
            on_activate = function()
                Gtk.main_quit()
            end
        }
    }
    menu:show_all()
    menu:popup(nil, nil, nil, event_button, event_time)
end

function ui.agenda:on_popup_menu(ev, time)
    create_menu(ev, time)
end