#!/usr/bin/env lua5.1

--[[--
 @package   Contacts
 @filename  src/init.lua
 @version   3.0
 @autor     Diaz Urbaneja Victor Diego Alejandro <sodomon2@gmail.com>
 @date      04.03.2021 22:20:37 -04
]]

package.path = package.path .. ';./?/init.lua;lib/?.lua'
require 'lib'

require ("tray")
require ("contact")
require ("app")
require ("users")

ui.main_window:show_all()
Gtk.main()
