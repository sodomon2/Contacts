--[[--
 @package   Contacts
 @filename  src/users.lua
 @version   3.0
 @autor     Diaz Urbaneja Victor Diego Alejandro <sodomon2@gmail.com>
 @date      04.03.2021 23:03:12 -04
]]

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
