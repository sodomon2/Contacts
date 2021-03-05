--[[!
 @package   
 @filename  funciones.lua
 @version   1.0
 @autor     Díaz Devera Víctor Diex Gamar <vitronic2@gmail.com>
 @date      09.09.2017 18:33:23 -04
]]--

local funciones     = class("funciones")

-- similar a empty
function funciones:isempty(s)
  return s == nil or s == ''
end

-- Formatea una fecha a formato sql
-- @param fecha string: 09/08/2017 DD/MM/YYYY
-- @return string | string: 2017-08-09 YYYY-MM-DD
function funciones:fecha_sql(fecha)
	local  dia, mes, anio = fecha:match("([^/]+)/([^/]+)/([^/]+)")
	return string.format("%s-%s-%s", anio , mes , dia)
end

-- Formatea una fecha a formato venezolano
-- @param fecha string: 2017-08-09 YYYY-MM-DD
-- @return string | string: 09/08/2017 DD/MM/YYYY
function funciones:format_fecha(fecha)
	local  anio,mes,dia = fecha:match("([^/]+)-([^/]+)-([^/]+)")
	return string.format("%s/%s/%s", dia , mes , anio)
end

-- Convierte una fecha a timestamp
-- @param fecha string: 2017-08-09 YYYY-MM-DD
-- @return string | integer:  timestamp
function funciones:date2timestamp(fecha)
	local  dia, mes, anio = fecha:match("([^/]+)/([^/]+)/([^/]+)")
	return os.time({year = anio, month = mes, day = dia})
end

--tomado de https://stackoverflow.com/questions/656199/search-for-an-item-in-a-lua-list
function funciones:buscar_in_array(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

--tomado de http://lua-users.org/wiki/SplitJoin
--similar a explode de php
function funciones:split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

--remueve todos los espacios de una cadena
function funciones:all_trim(s)
   return s:gsub(" ", "")
end

-- Remueve espacios iniciales y finales de una cadena
function funciones:trim(s)
  return (string.gsub (string.gsub (s, "%s+$", ""), "^%s+", ""))
end 

return funciones

