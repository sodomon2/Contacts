#!/usr/bin/env lua5.1

require('lib.middleclass')                  -- La libreria middleclass me da soporte a OOP
funcion         = require('lib.funciones')  -- En lib/funciones guardare todas las funciones generales
comun           = require('lib.comun')      -- Similar a funciones pero mas comun
db              = require('lib.db')         -- La super libreria para el acceso a sqlite

local lgi       = require 'lgi'             -- La libreria que me permitira usar GTK
local GObject   = lgi.GObject               -- Parte de lgi
local Gdk       = lgi.Gdk                   -- parte de lgi
local GLib      = lgi.GLib                  -- para el treeview
local Notify    = lgi.Notify                -- la libreria que me permite hacer notificaciones de escritorio
local Gtk       = lgi.require('Gtk', '3.0') -- El objeto GTK

local assert    = lgi.assert
local builder   = Gtk.Builder()

assert(builder:add_from_file('vistas/agenda.ui'))
local ui = builder.objects

local login_window    = ui.dialog_login
local window_user     = ui.window_user
local main_window     = ui.main_window
local about_window    = ui.about_window

local agenda          = builder:get_object('agenda')             -- Invoco el objeto agenda de agenda.ui

local btn_cancel      = builder:get_object('btn_cancel')         -- Invoco el objeto btn_cancel de agenda.ui
local btn_ok          = builder:get_object('btn_ok')             -- Invoco el objeto btn_ok de agenda.ui

local btn_user        = builder:get_object('btn_user')           -- Invoco el objeto btn_user de agenda.ui
local btn_user_ok     = builder:get_object('btn_user_ok')        -- Invoco el objeto btn_user_ok de agenda.ui
local btn_user_cancel = builder:get_object('btn_user_cancel')    -- Invoco el objeto btn_user_cancel de agenda.ui

local input           = builder:get_object('entry_user')         -- Invoco el objeto entry_user de agenda.ui
local password        = builder:get_object('entry_password')     -- Invoco el objeto entry_password de agenda.ui
local contactos_view  = builder:get_object('contactos_view')     -- Invoco el objeto entry_password de agenda.ui
local label_usuario   = builder:get_object('label_usuario')      -- Invoco el objeto label_usuario de agenda.ui

Notify.init("Inicio las notificaciones")
message = Notify.Notification.new

local function aceptar()
    db:open()
	local sql = "select id_usuario from usuarios where usuario = '"..input.text.."' and contrasena = '"..password.text.."'"
	local result = db:get_var(sql)
	if result then
		welcome = message ("Agenda Personal","Bienvenido " .. input.text,"user")
		welcome:show()

		login_window:hide()
		main_window:show_all()
	else
		label_usuario.label = "contraseña o usuario incorrecto"
	end
end 

function btn_ok:on_clicked()
    aceptar()
end

function ui.entry_password:on_key_release_event(env)
    if ( env.keyval  == Gdk.KEY_Return ) then
      aceptar()     
    end
end

local btn_registrar   = builder:get_object('btn_registrar') -- Invoco el objeto btn_registrar de agenda.ui
local btn_reset       = builder:get_object('btn_reset')     -- Invoco el objeto btn_reset de agenda.ui

local function poblar_lista()
	db:open()
	local lista_contactos = builder:get_object('lista_contactos')
	lista_contactos:clear()
	local sql = "select * from contactos order by id_contacto desc"
	local consulta = db:get_results(sql)

	for i,item in pairs(consulta) do
		lista_contactos:append({
			item.id_contacto,
			item.nombre,
			item.numero,
			item.lugar,
			item.fecha_registro
		})
	end
end

poblar_lista()

local input_nombre = builder:get_object('entry_nombre') -- Invoco el objeto entry_nombre de agenda.ui
local input_numero = builder:get_object('entry_numero') -- Invoco el objeto entry_numero de agenda.ui
local input_lugar  = builder:get_object('entry_lugar')  -- Invoco el objeto entry_lugar de agenda.ui

local function insert_data()
	db:open()
	local sql = "insert into contactos(nombre,numero,lugar) values('"..input_nombre.text.."','"..input_numero.text.."','"..input_lugar.text .."')"
	local _numero = tonumber(input_numero.text)
	if input_nombre ~= "" and _numero ~= "" and input_lugar.text ~= "" then
		if (db:query(sql) == false) then
			print("error al insertar los datos")
			print(sql)
		else
			poblar_lista()
			input_numero.text = ""
			input_nombre.text = ""
			input_lugar.text  = ""
           
			contacto          = message ("Agenda Personal","Contacto añadido correctamente","user")
			contacto:show()
		end
	else
		print("error campos vacios")
	end
end

local function user_exist(user)
    db:open()
    local sql = "SELECT usuario from usuarios where usuario='"..user.."'"
    local resultado = db:get_var(sql)
    if (resultado) then
        return true
    else
        return false
    end
end

local input_usuario    = builder:get_object('entry_user_usuario')    -- Invoco el objeto entry_user_user de agenda.ui
local input_contrasena = builder:get_object('entry_user_contrasena') -- Invoco el objeto entry_user_contrasena de agenda.ui
local label_mensaje    = builder:get_object('label_mensaje')         -- Invoco el objeto label_mensaje de agenda.ui

local function insert_user()
	db:open()
	local sql = "insert into usuarios(usuario,contrasena,estatus) values('"..input_usuario.text.."','"..input_contrasena.text.."','t')"
	if input_usuario.text ~= "" and input_contrasena.text ~= "" then
        if (user_exist(input_usuario.text) == true )then
            label_mensaje.label = "el usuario existe"
            return false
        end
		if (db:query(sql) == false) then
			print("error al insertar los datos")
			print(sql)
		else
			input_usuario.text = ""
			input_contrasena.text = ""
			label_mensaje.label = "usuario creado correctamente"
		end
	else
		label_mensaje.label = "error campos vacios"
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
    if main_window.is_active then
        ui.dialog_login:hide()
    else
        if visible then
            ui.dialog_login:show_all()
        else
            ui.dialog_login:hide()
        end
    end 
end

function agenda:on_activate()
	trayicon()
end

function btn_registrar:on_clicked()
	insert_data()
end

function btn_user_ok:on_clicked()
	insert_user()
end

function btn_user:on_clicked()
    ui.window_user:show_all()
    ui.dialog_login:hide()
end

function btn_user_cancel:on_clicked()
	ui.dialog_login:show_all()
    ui.window_user:hide()
end

function btn_cancel:on_clicked()
	Gtk.main_quit()
end

function ui.menu_about:on_clicked()
    ui.about_window:run()
    ui.about_window:hide()
end

function ui.menu_quit_login:on_clicked()
    main_window:hide()
    login_window:show_all()
end

function main_window:on_destroy()
	Gtk.main_quit()
end

-- Show window and start the loop.
login_window:show_all()
Gtk.main()
