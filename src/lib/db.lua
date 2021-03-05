--[[
         ____  _     _             _
        / ___|(_) __| | ___  _ __ (_) __ _
        \___ \| |/ _` |/ _ \| '_ \| |/ _` |
         ___) | | (_| | (_) | | | | | (_| |
        |____/|_|\__,_|\___/|_| |_|_|\__,_|
Copyright (c) 2017  Díaz  Víctor  aka  (Máster Vitronic)
<vitronic2@gmail.com>   <mastervitronic@vitronic.com.ve>

]]--


local sqlite3   = require('lsqlite3')
local db		= class('db')

--conexion a la base de datos
function db:open()
	if self.db and self.db:isopen() then
		return false
	else
		self.db = assert(sqlite3.open('db.db'))
		local sql = [[
		--	PRAGMA key = 'vitronic';
		--	PRAGMA cipher_page_size = '4096';
		]]
		local r = self.db:exec(sql)
		return (r == 0)
	end
end

--retorna todo el objeto db
function db:raw_db()
    return self.db
end

--cierra la conexion
function db:close()
    self.db:close()
end

-- Ejecuta un query
-- @param query string: el query a ser ejecutado
-- @return boolean: true si fue exitoso, false en caso contrario
function db:query(query)
	local r = self.db:exec(query)
	return (r == 0)
end

-- Ejecuta un query
-- @param query string: el query a ser ejecutado
-- @return table: las columnas con el resultado
function db:get_results(query)
    local r = {}
    local stmt = self.db:prepare(query)
    for row in stmt:nrows() do
        table.insert(r,row)
    end
    stmt:finalize()
    return r
end

-- Ejecuta una consulta y retorna el primer valor
-- encontrado si no se le pasa la clausula where
-- @param query string: la consulta a ejecutar
-- @return string | number: the result
function db:get_var(query)
    local res = self:get_results(query)
    local value
    if next(res) then
        for _,v in pairs(res[1]) do
            value = v
        end
    end
    return value
end

-- Ejecuta una consulta y retorna el resultado
-- en un array asociativo campo=>valor
-- @param query string: la consulta a ejecutar
-- @return array|table the result
function db:get_rows(query)
    local res = self:get_results(query)
    local value = {}
    if next(res) then
        for campo,valor in pairs(res[1]) do
            value[campo] = valor
        end
    end
    return value
end

-- retorna una version limpia y desinfectada de la entrada
-- (version para la base de datos)
-- @param string
-- @return string: desinfectados
function db:escape(s)
	return (string.gsub (string.gsub (s:gsub("'", "''"), "%s+$", ""), "^%s+", ""))
    --return s:gsub("'", "''")
end

-- retorna una version limpia y desinfectada de la entrada
-- @param string | array
-- @return string | array desinfectados
function db:sanitize(q)
    if type(q) == "string" then
        q = trim(self:escape(q))
        return q
    elseif type(q) == "table" then
        local limpio = {}
        for k,v in pairs(q) do
            limpio[k] = trim(self:escape(q[k]))
        end
        return limpio
    end
    return q
end


--[[Inicio del CRUD Luachi]]--

--Array o tabla datos para ser usado con los metodos crud
local datos = {}
function db:datos(array)
    datos = array
end

--agrega un nuevo indice al arreglo datos
function db:add_dato(campos)
    for k,v in pairs(campos) do
        datos[k] = campos[k]
    end
    datos = datos
end

--Remueve un campo del array o tabla datos
function db:remover(campos)
    for k,v in pairs(campos) do
        datos[v] = nil
    end
    datos = datos
end

--control sanitario para crud
function db:check(condicion,array,tabla,campo,id)

    local update = ' '
    if id then
        update = " and "..campo.."!='"..id.."'";
    end
    if (type(array) == "table") then
        if condicion == 'existe' then
            for campo,valor in pairs(array) do
                local sql = "select "..valor.." from "..tabla.." where "..valor.."='"..datos[valor].."' "..update..""
                if db:get_var(sql) then
                    return {campo=valor,valor=datos[valor]} -- valor existe, informo del campo y del valor
                end
            end
            return false --retorno false por que no existe este valor en el campo dado de  la base de datos
        elseif condicion == 'nulo' then
            for campo,valor in pairs(array) do
                if datos[valor] == nil or datos[valor] == '' then
                    return valor -- retorno el campo que es nulo o empty
                end
            end
            return false --retorno false por que nada es nulo o empty
        end
    end

end

--crea una sentencia SQL insert a partir del asociativo arrray o tabla datos
function db:crear_insert(tabla)

    local function table_val(array)
        local valores = {}
        for campo, valor in pairs(array) do
            local val = {}
            val = "'"..db:escape(valor).."'"
            table.insert(valores,val)
        end
        return table.concat(valores,",")
    end

    local function table_keys(array)
        local campos = {}
        for campo, valor in pairs(array) do
            local key = {}
            key = campo
            table.insert(campos,key)
        end
        return table.concat(campos,",")
    end
    return 'insert into '..tabla..' ('..table_keys(datos)..') '..'values ('..table_val(datos)..')'

end
--crea una sentencia SQL update a partir del asociativo arrray o tabla datos
function db:crear_update(tabla,key,id)
    local values = {}
    for campo, valor in pairs(datos) do
        local key = {}
        key = campo.."=".."'"..valor.."'"
        table.insert(values,key)
    end
    return 'update '..tabla..' set '..table.concat(values,",") .. ' where ' .. key .. "='" .. id .."'"
end

--crea una sentencia SQL delete
--@params string
function db:crear_delete(tabla,campo,id)
        return "delete from "..tabla.." where "..campo.."='"..id.."'";
end

--[[Fin del CRUD Luachi]]--


return db
