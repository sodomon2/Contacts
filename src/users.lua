--[[--
 @package   Contacts
 @filename  src/users.lua
 @version   3.0
 @autor     Diaz Urbaneja Victor Diego Alejandro <sodomon2@gmail.com>
 @date      04.03.2021 23:03:12 -04
]]

function aceptar()
	db:open()
	local sql = "select id_usuario from usuarios where usuario = '"..ui.entry_username.text.."' and contrasena = '"..ui.entry_password.text.."'"
	local result = db:get_var(sql)
	if result then
		ui.stack:set_visible_child_name('contacts')
		notification("Agenda Personal","Bienvenido " .. ui.entry_username.text)
	else
		ui.revealer_message:set_reveal_child(true)
		ui.label_mensaje.label = "Usuario o contraseña incorrectos"
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
	local sql = "insert into usuarios(usuario,contrasena,estatus) values('"..ui.entry_username.text.."','"..ui.entry_password.text.."','t')"
	if ui.entry_username.text ~= "" and ui.entry_password.text ~= "" then
		if (user_exist(ui.entry_username.text) == true )then
			ui.label_mensaje.label = "El usuario existe"
			return false
		end
		if (db:query(sql) == false) then
			print("error al insertar los datos")
			print(sql)
		else
			ui.entry_username.text = ""
			ui.entry_password.text = ""
		end
	else
		ui.label_mensaje.label = "Error: campos vacíos"
	end
end

function ui.entry_password:on_key_release_event(env)
	if ( env.keyval  == Gdk.KEY_Return ) then
		insert_user()
	end
end
