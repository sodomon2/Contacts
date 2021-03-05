#!/usr/bin/env lua5.1

package.path = package.path .. ';./?/init.lua;lib/?.lua'
require 'lib'

local assert    = lgi.assert
local builder   = Gtk.Builder()

assert(builder:add_from_file('../data/agenda.ui'))
local ui = builder.objects

function notification(title,msg)
		Notify.init("init")
		message = Notify.Notification.new
		msg = message(title,msg)
		msg:show()
end

function aceptar()
    db:open()
	local sql = "select id_usuario from usuarios where usuario = '"..ui.entry_user.text.."' and contrasena = '"..ui.entry_password.text.."'"
	local result = db:get_var(sql)
	if result then
		notification("Agenda Personal","Bienvenido " .. ui.entry_user.text)

		ui.dialog_login:hide()
		ui.main_window:show_all()
	else
		ui.label_usuario.label = "Usuario o contraseña incorrectos"
	end
end

function ui.btn_ok:on_clicked()
    aceptar()
end

function ui.entry_password:on_key_release_event(env)
    if ( env.keyval  == Gdk.KEY_Return ) then
      aceptar()
    end
end

function poblar_lista()
	db:open()
	ui.lista_contactos:clear()
	local sql = "select * from contactos order by id_contacto desc"
	local consulta = db:get_results(sql)

	for i,item in pairs(consulta) do
		ui.lista_contactos:append({
			item.id_contacto,
			item.nombre,
			item.numero,
			item.lugar,
			item.fecha_registro
		})
	end
end
poblar_lista()

function insert_data()
	db:open()
	local sql = "insert into contactos(nombre,numero,lugar) values('"..ui.entry_nombre.text.."','"..ui.entry_numero.text.."','"..ui.entry_lugar.text .."')"
	local _numero = tonumber(ui.entry_numero.text)
	if ui.entry_nombre.text ~= "" and _numero ~= "" and ui.entry_lugar.text ~= "" then
		if (db:query(sql) == false) then
			print(sql)
		else
			poblar_lista()
			ui.entry_numero.text = ""
			ui.entry_nombre.text = ""
			ui.entry_lugar.text  = ""

			notification("Agenda Personal", "Contacto añadido correctamente")
		end
	else
		print("error campos vacios")
	end
end

function user_exist(user)
    db:open()
    local sql = "SELECT usuario from usuarios where usuario='" ..user.. "'"
    local resultado = db:get_var(sql)
    if (resultado) then
        return true
    else
        return false
    end
end

function insert_user()
	db:open()
	local sql = "insert into usuarios(usuario,contrasena,estatus) values('"..ui.entry_user_usuario.text.."','"..ui.entry_user_contrasena.text.."','t')"
	if ui.entry_user_usuario.text ~= "" and ui.entry_user_contrasena.text ~= "" then
        if (user_exist(ui.entry_user_usuario.text) == true )then
            ui.label_mensaje.label = "El usuario existe"
            return false
        end
		if (db:query(sql) == false) then
			print("error al insertar los datos")
			print(sql)
		else
			ui.entry_user_usuario.text = ""
			ui.entry_user_contrasena.text = ""
			ui.label_mensaje.label = "Usuario creado con exito"
		end
	else
		ui.label_mensaje.label = "Error: campos vacíos"
	end
end

function ui.entry_user_contrasena:on_key_release_event(env)
    if ( env.keyval  == Gdk.KEY_Return ) then
      insert_user()
    end
end

local visible = false

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

function ui.btn_registrar:on_clicked()
	insert_data()
end

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

-- Show window and start the loop.
ui.dialog_login:show_all()
Gtk.main()
