#!/usr/bin/env lua5.1

require('lib.middleclass')                  -- La libreria middleclass me da soporte a OOP
require('languages.init')					-- la libreria de lenguajes
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

setLang("en_us")

-- label
builder:get_object('label_user').label						= getLINE("user")
builder:get_object('label_password').label 	     		  = getLINE("password")
builder:get_object('label_create_user').label 	  		  = getLINE("create_user")
builder:get_object('label_create_password').label 			= getLINE("create_password")

--botones
builder:get_object('btn_ok').label          				  = getLINE("accept")
builder:get_object('btn_cancel').label      				  = getLINE("cancel")
builder:get_object('btn_user_ok').label     				  = getLINE("user_create")
builder:get_object('btn_user_cancel').label 			      = getLINE("cancel")
builder:get_object('btn_registrar').label   				  = getLINE("register")
builder:get_object('btn_reset').label       				  = getLINE("clear")

-- entry
builder:get_object('entry_user').placeholder_text     		= getLINE("user_entry")
builder:get_object('entry_password').placeholder_text 		= getLINE("pass")
builder:get_object('entry_user_usuario').placeholder_text     = getLINE("user_entry")
builder:get_object('entry_user_contrasena').placeholder_text  = getLINE("pass")

builder:get_object('entry_nombre').placeholder_text  		 = getLINE("name")
builder:get_object('entry_numero').placeholder_text  	     = getLINE("number")
builder:get_object('entry_lugar').placeholder_text   	     = getLINE("country")
builder:get_object('entry_busqueda').placeholder_text   	  = getLINE("insert")

-- windows
builder:get_object('dialog_login').title  					  = getLINE("login")
builder:get_object('window_user').title   				      = getLINE("user_window")
builder:get_object('about_window').title  					  = getLINE("about")
builder:get_object('main_window').title   					  = getLINE("window")

-- menus
builder:get_object('menu_quit_login').text  				    = getLINE("exit")
builder:get_object('menu_about').text       				    = getLINE("about")

local agenda          = builder:get_object('agenda')             -- Invoco el objeto agenda de agenda.ui

local contactos_view  = builder:get_object('contactos_view')     -- Invoco el objeto entry_password de agenda.ui

local function notification(title,subtitle,msg,img)
    Notify.init("init")
    message = Notify.Notification.new
		msg = message(title,subtitle or nil,msg)
		msg:show()
end

local function aceptar()
    db:open()
	local sql = "select id_usuario from usuarios where usuario = '"..ui.entry_user.text.."' and contrasena = '"..ui.entry_password.text.."'"
	local result = db:get_var(sql)
	if result then
		notification("Agenda Personal","Bienvenido " .. ui.entry_user.text)

		ui.dialog_login:hide()
		ui.main_window:show_all()
	else
		ui.label_usuario.label = getLINE ("user_menssage")
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

local function insert_data()
	db:open()
	local sql = "insert into contactos(nombre,numero,lugar) values('"..ui.entry_nombre.text.."','"..ui.entry_numero.text.."','"..ui.entry_lugar.text .."')"
	local _numero = tonumber(ui.entry_numero.text)
	if ui.entry_nombre.text ~= "" and _numero ~= "" and ui.entry_lugar.text ~= "" then
		if (db:query(sql) == false) then
			print("error al insertar los datos")
			print(sql)
		else
			poblar_lista()
			ui.entry_numero.text = ""
			ui.entry_nombre.text = ""
			ui.entry_lugar.text  = ""

			notification("Agenda Personal","Contacto añadido correctamente")
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

local function insert_user()
	db:open()
	local sql = "insert into usuarios(usuario,contrasena,estatus) values('"..ui.entry_user_usuario.text.."','"..ui.entry_user_contrasena.text.."','t')"
	if ui.entry_user_usuario.text ~= "" and ui.entry_user_contrasena.text ~= "" then
        if (user_exist(ui.entry_user_usuario.text) == true )then
            ui.label_mensaje.label = getLINE ("exist_user")
            return false
        end
		if (db:query(sql) == false) then
			print("error al insertar los datos")
			print(sql)
		else
			ui.entry_user_usuario.text = ""
			ui.entry_user_contrasena.text = ""
			ui.label_mensaje.label = getLINE("user_valid")
		end
	else
		ui.label_mensaje.label = getLINE("error")
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

function agenda:on_activate()
	trayicon()
end

function create_menu(event_button, event_time)
    menu = Gtk.Menu {
        Gtk.ImageMenuItem {
            label = getLINE("close"),
            on_activate = function()
                Gtk.main_quit()
            end
        }
    }
    menu:show_all()
    menu:popup(nil, nil, nil, event_button, event_time)
end

function agenda:on_popup_menu(ev, time)
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
