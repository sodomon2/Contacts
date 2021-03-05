#!/usr/bin/env lua5.1

package.path = package.path .. ';./?/init.lua;lib/?.lua'
require 'lib'

require ("tray")
require ("contact")
require ("app")
require ("users")

ui.dialog_login:show_all()
Gtk.main()
